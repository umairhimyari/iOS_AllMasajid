//
//  IqamahConfigureTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/10/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class IqamahConfigureTVC: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var namazTitleLBL: UILabel!
    
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var startDateTF: UITextField!
    @IBOutlet weak var endDateTF: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

