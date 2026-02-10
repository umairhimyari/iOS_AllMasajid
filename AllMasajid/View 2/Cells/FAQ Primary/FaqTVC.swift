//
//  FaqTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/04/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class FaqTVC: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myView.cornerRadius = 22.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
