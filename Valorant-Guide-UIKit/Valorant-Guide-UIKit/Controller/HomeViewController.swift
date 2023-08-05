//
//  HomeViewController.swift
//  Valorant-Guide-UIKit
//
//  Created by Mohamed Salah on 04/08/2023.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var agentsCollectionView: UICollectionView!
    @IBOutlet weak var agentPages: UIPageControl!
    var agentsData: AgentsParser?
    private let provider = NetworkAPIProvider()
    var currentPage = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agentsCollectionView.register(UINib(nibName: K.cellsResuable.agentsCellIdentifier, bundle: nil), forCellWithReuseIdentifier: K.cellsResuable.agentsCellIdentifier)
        getAgentsData()
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
                return cell
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: K.cellsResuable.agentsCellIdentifier, for: indexPath)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//    }
    
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
                    print("3ash")
                    self.agentsData = data
                    self.agentPages.numberOfPages = (self.agentsData?.data.count)!
                    self.agentsCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
