//
//  VerseTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import UIKit

class VerseTVC: UITableViewCell {

    @IBOutlet weak var verseLBL: UILabel!
    @IBOutlet weak var translationLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(item: Verse) {
        verseLBL.text = item.name
        translationLBL.text = item.verseKey
    }
}
