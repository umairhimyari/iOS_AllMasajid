//
//  MyEventsTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/10/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class MyEventsTVC: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    
    @IBOutlet weak var dateLBL: UILabel!
    @IBOutlet weak var removeBTN: UIButton!
    @IBOutlet weak var reScheduleBTN: UIButton!
    @IBOutlet weak var verifyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
