//
//  EventTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 16/05/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class EventTVC: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    
    @IBOutlet weak var dateLBL: UILabel!
    @IBOutlet weak var favoriteBTN: UIButton!
    @IBOutlet weak var verifyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
