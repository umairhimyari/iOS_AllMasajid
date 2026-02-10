//
//  MyMasajidTableViewCell.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 1/10/19.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import UIKit

class MyMasajidTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnOption: UIButton!
    
    @IBOutlet weak var lblMasjidName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.backgroundColor = #colorLiteral(red: 0, green: 0.5399764776, blue: 0.8613250852, alpha: 1)//UIColor(rgb: 0x0d74d3)
     
 
    }
    override func layoutSubviews() {
        let radius = containerView.frame.size.height/2
       
       containerView.cornerRadius = radius
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
