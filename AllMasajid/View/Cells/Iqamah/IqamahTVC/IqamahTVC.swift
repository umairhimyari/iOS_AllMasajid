//
//  IqamahTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class IqamahTVC: UITableViewCell {
    
    @IBOutlet weak var isReachableVie: UIView!
    @IBOutlet weak var distanceLBL: UILabel!
    @IBOutlet weak var masjidLBL: UILabel!
    @IBOutlet weak var nextTimeLBL: UILabel!
    @IBOutlet weak var timeLBL: UILabel!
    @IBOutlet weak var timeRemainingLBL: UILabel!
    
    @IBOutlet weak var viewAllBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
