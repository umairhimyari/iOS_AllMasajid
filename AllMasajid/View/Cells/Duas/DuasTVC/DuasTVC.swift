//
//  DuasTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class DuasTVC: UITableViewCell {

    @IBOutlet weak var favoruiteBtn: UIButton!
    @IBOutlet weak var duaReasonLabel: UILabel!
    @IBOutlet weak var duaLabel: UILabel!
    @IBOutlet weak var translation2Label: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
