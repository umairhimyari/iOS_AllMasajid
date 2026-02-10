//
//  SettingsSectionTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class SettingsSectionTVC: UITableViewCell {

    @IBOutlet weak var sectionIMG: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var descriptionLBL: UILabel!
    @IBOutlet weak var dropDownBTN: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
