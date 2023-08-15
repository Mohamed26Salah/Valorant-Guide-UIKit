//
//  Extenstions.swift
//  Valorant-Guide-UIKit
//
//  Created by Mohamed Salah on 05/08/2023.
//

import UIKit

extension UIViewController {
    func pushToViewController(identifier: String, withObject object: Any? = nil, animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: identifier)
            if let objectToSend = object {
                destinationViewController.setValue(objectToSend, forKey: "receivedObject")
            }
            navigationController?.pushViewController(destinationViewController, animated: animated)
    }
    func pushToViewController<model: UIViewController>(modelDTO: model.Type, identifier: String, withObject object: Any? = nil, animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let destinationViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? model {
            if let objectToSend = object {
//                destinationViewController.setValue(objectToSend, forKey: "receivedObject")
                
            }
            navigationController?.pushViewController(destinationViewController, animated: animated)
        }
    }
}
