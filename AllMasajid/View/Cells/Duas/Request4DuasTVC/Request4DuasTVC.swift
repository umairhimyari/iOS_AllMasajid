//
//  Request4DuasTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class Request4DuasTVC: UITableViewCell {

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var bodyLBL: UILabel!
    
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
    }
}
