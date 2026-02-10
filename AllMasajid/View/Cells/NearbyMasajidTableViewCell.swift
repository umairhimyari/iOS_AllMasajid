//
//  NearbyMasajidTableViewCell.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 10/6/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit

class NearbyMasajidTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var lblMasjidName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var btnOption: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
          //containerView.backgroundColor = UIColor(rgb: 0x0d74d3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        let radius = containerView.frame.size.height/2
    
        containerView.cornerRadius = radius
    }
}
