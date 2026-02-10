//
//  ICPrayerTimesTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 18/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class ICPrayerTimesTVC: UITableViewCell {

    @IBOutlet weak var myIMG: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var timeLBL: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(image: UIImage, titleTxt: String, timeTxt: String){
        
    }
}
