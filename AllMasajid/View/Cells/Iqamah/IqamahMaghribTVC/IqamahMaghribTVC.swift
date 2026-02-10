//
//  IqamahMaghribTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 22/10/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class IqamahMaghribTVC: UITableViewCell {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var namazTitle: UILabel!
    @IBOutlet weak var minuteTF: UITextField!
    
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
