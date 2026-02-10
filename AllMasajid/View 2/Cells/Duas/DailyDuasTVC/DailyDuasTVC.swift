//
//  DailyDuasTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class DailyDuasTVC: UITableViewCell {
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myView.cornerRadius = 22.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupHow2UseAppCell(model: How2UseAppCategories){
        titleLabel.text = model.display_name
        let image = model.image
        
        if image != ""{
            GetImage.getImage(url: URL(string: image)!, image: myImageView)
        }
    }
    
    func setupHow2UseAppCell2(title: String){
        titleLabel.text = title
        myImageView.image = #imageLiteral(resourceName: "allMlogo")
    }
}
