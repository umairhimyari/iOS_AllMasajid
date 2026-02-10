//
//  MasajidTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 12/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class MasajidTVC: UITableViewCell {

    @IBOutlet weak var distanceLBL: UILabel!
    @IBOutlet weak var masjidNameLBL: UILabel!
    @IBOutlet weak var registerBTN: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
