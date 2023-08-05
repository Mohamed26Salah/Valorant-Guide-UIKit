//
//  AgentDescriptionViewController.swift
//  Valorant-Guide-UIKit
//
//  Created by Mohamed Salah on 05/08/2023.
//

import UIKit

class AgentDescriptionViewController: UIViewController {
    var agent: AgentsDatum?
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var agentImage: UIImageView!
    @IBOutlet weak var agentName: UILabel!
    @IBOutlet weak var agentDescription: UILabel!
    @IBOutlet weak var agentTextFieldDescription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        showAgentData()
        agentName.isHidden = true
        agentDescription.isHidden = true
        // Do any additional setup after loading the view.
    }
    func showAgentData() {
        guard let agentData = agent,
              let backgroundUrl = URL(string: agentData.background ?? K.imageOptionals.graffittiImage),
              let fullPortraitUrl = URL(string: agentData.fullPortrait ?? K.imageOptionals.graffittiImage) else {
            return
        }
        backgroundImage.sd_setImage(with: backgroundUrl)
        agentImage.sd_setImage(with: fullPortraitUrl)
        agentName.text = agentData.displayName
        agentDescription.text = agentData.description
        agentTextFieldDescription.text = agentData.description
        
    }
    
    
}
