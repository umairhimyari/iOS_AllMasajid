//
//  PrayerTimesTableViewCell.swift
//  AllMasajid
//
//  Created by 12345 on 9/16/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import UIKit

class PrayerTimesTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblPrayerTime: UILabel!
    @IBOutlet weak var btnSwitchAlarm: UIButton!
    @IBOutlet weak var lblPrayerName: UILabel!
    
    @IBOutlet weak var imgPrayerIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = #colorLiteral(red: 0, green: 0.5399764776, blue: 0.8613250852, alpha: 1)//UIColor(rgb: 0x0d74d3)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
