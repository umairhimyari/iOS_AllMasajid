//
//  UserRequest4DuasTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class UserRequest4DuasTVC: UITableViewCell {

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var bodyLBL: UILabel!
    @IBOutlet weak var expiryLBL: UILabel!
    
    @IBOutlet weak var removeBTN: UIButton!
    @IBOutlet weak var extendBTN: UIButton!
    
    @IBOutlet weak var editBTN: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(item: DuaAppealsModel){
        titleLBL.text = item.title
        bodyLBL.text = item.appeal
        if item.remainingDaysStatus == false {
            expiryLBL.text = "Expired"
            expiryLBL.textColor = .systemRed
        }else{
            expiryLBL.text = "Expiry: \(item.remainingDaysText)"
            expiryLBL.textColor = .white
        }
    }
    
}
