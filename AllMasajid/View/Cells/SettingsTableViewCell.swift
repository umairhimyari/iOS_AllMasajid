//
//  SettingsTableViewCell.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 10/24/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    
  
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
 
    @IBOutlet weak var btnArrow: UIButton!

 
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
