//
//  MapsTableViewCell.swift
//  Valorant-Guide-UIKit
//
//  Created by Mohamed Salah on 05/08/2023.
//

import UIKit
import SwipeCellKit
class MapsTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var mapLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
