//
//  NotificationsListTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class NotificationsListTVC: UITableViewCell {

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var bodyLBL: UILabel!
    @IBOutlet weak var typeLBL: UILabel!
    @IBOutlet weak var myIMG: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
