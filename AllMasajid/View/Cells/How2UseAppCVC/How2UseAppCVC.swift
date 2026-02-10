//
//  How2UseAppCVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 18/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class How2UseAppCVC: UICollectionViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var detailLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCellAppSetup(item: How2UseAppCategories){
        
        detailLBL.text = item.description
        
        let image = item.image
        
        if image != ""{
            GetImage.getImage(url: URL(string: image)!, image: myImageView)
        }
    }
    
    func configureCellAppSetup2(desc: String, image: String){
        
        detailLBL.text = desc
        myImageView.image = UIImage(named: image)
    }
    
}
