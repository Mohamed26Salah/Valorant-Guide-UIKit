//
//  HomeViewController.swift
//  Valorant-Guide-UIKit
//
//  Created by Mohamed Salah on 04/08/2023.
//

import UIKit
import SDWebImage
import SwipeCellKit

//1-auto scroll problem
//2-Both Scrolls Interfear with each other
//3-Navigation Extention is Not Working why ?
//4-scrollView Height ??
class HomeViewController: UIViewController {
    
    @IBOutlet weak var agentsCollectionView: UICollectionView!
    @IBOutlet weak var agentPages: UIPageControl!
    @IBOutlet weak var mapsTableView: UITableView!
    
    var agentsData: AgentsParser?
    var mapsData: MapsParser?
    private let provider = NetworkAPIProvider()
    var currentPage = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        agentsCollectionView.register(UINib(nibName: K.cellsResuable.agentsCellIdentifier, bundle: nil), forCellWithReuseIdentifier: K.cellsResuable.agentsCellIdentifier)
        mapsTableView.register(UINib(nibName: K.cellsResuable.mapsCellIdentifier, bundle: nil), forCellReuseIdentifier: K.cellsResuable.mapsCellIdentifier)
        getAgentsData()
        getMapsData()
        startAutoScroll()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
    }
    
    
}
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return agentsData?.data.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let agentData = agentsData {
            if agentData.data[indexPath.row].isPlayableCharacter {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.cellsResuable.agentsCellIdentifier, for: indexPath) as! AgentsCollectionViewCell
                
                if let url = URL(string: (agentData.data[indexPath.row].displayIcon) ) {
                    cell.image.sd_setImage(with: url)
                }
                cell.label.text = agentData.data[indexPath.row].displayName
                cell.layer.cornerRadius = 10  // Adjust the value as needed
                cell.layer.masksToBounds = true
                return cell
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: K.cellsResuable.agentsCellIdentifier, for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let agent = agentsData?.data[indexPath.row] {
//            pushToViewController(modelDTO: AgentDescriptionViewController, identifier: K.viewsControllers.agentDescriptionController, withObject: agent)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let destinationViewController = storyboard.instantiateViewController(withIdentifier: K.viewsControllers.agentDescriptionController) as? AgentDescriptionViewController {
                destinationViewController.agent = agent
                navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = agentsCollectionView.frame.width
        currentPage = Int(targetContentOffset.pointee.x / pageWidth)
        //        print("currentPage: \(currentPage)")
        startAutoScroll()
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    //    }lastContentOffset = scrollView.contentOffset
    
}
extension HomeViewController {
    func startAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func scrollToNextPage() {
        currentPage = (currentPage + 1) % (agentsData?.data.count ?? 1)
        //        print("scrollToNextPage - currentPage: \(currentPage)")
        let indexPath = IndexPath(row: currentPage, section: 0)
        agentsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        agentPages.currentPage = currentPage
    }
}
extension HomeViewController {
    func getAgentsData() {
        let baseURL = URL(string: K.Links.apiLink)
        guard let apiURL = baseURL else {
            fatalError("Failed to create baseURL")
        }
        let apiHandler = APIClient(baseURL: apiURL, apiProvider: provider)
        apiHandler.fetchResourceData(modelDTO: agentsData, resource: URLHeads.agents.rawValue, completion: { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.agentsData = data
                    self.agentPages.numberOfPages = (self.agentsData?.data.count)!
                    self.agentsCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    func getMapsData() {
        let baseURL = URL(string: K.Links.apiLink)
        guard let apiURL = baseURL else {
            fatalError("Failed to create baseURL")
        }
        let apiHandler = APIClient(baseURL: apiURL, apiProvider: provider)
        apiHandler.fetchResourceData(modelDTO: mapsData, resource: URLHeads.maps.rawValue, completion: { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.mapsData = data
                    self.mapsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}


extension HomeViewController: UITableViewDataSource, SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.mapsData?.data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")

            return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapsData?.data.count ?? 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let mapData = mapsData {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellsResuable.mapsCellIdentifier, for: indexPath) as! MapsTableViewCell
            
            cell.delegate = self
            
            if let url = URL(string: (mapData.data[indexPath.row].listViewIcon) ) {
                cell.mapImage.sd_setImage(with: url)
            }
            cell.mapLabel.text = mapData.data[indexPath.row].displayName
            cell.layer.cornerRadius = 10  // Adjust the value as needed
            cell.layer.masksToBounds = true
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: K.cellsResuable.mapsCellIdentifier, for: indexPath)
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let mapData = mapsData {
//            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellsResuable.mapsCellIdentifier, for: indexPath) as! MapsTableViewCell
//
//            if let url = URL(string: (mapData.data[indexPath.row].listViewIcon) ) {
//                cell.mapImage.sd_setImage(with: url)
//            }
//            cell.mapLabel.text = mapData.data[indexPath.row].displayName
//            cell.layer.cornerRadius = 10  // Adjust the value as needed
//            cell.layer.masksToBounds = true
//            return cell
//        }
//        return tableView.dequeueReusableCell(withIdentifier: K.cellsResuable.mapsCellIdentifier, for: indexPath)
//    }
//
    
}
