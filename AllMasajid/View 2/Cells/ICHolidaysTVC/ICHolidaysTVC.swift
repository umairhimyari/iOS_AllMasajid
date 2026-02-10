//
//  ICHolidaysTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 16/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class ICHolidaysTVC: UITableViewCell {

    @IBOutlet weak var englishDateLBL: UILabel!
    @IBOutlet weak var islamicDateLBL: UILabel!
    @IBOutlet weak var eventNameLBL: UILabel!
    @IBOutlet weak var timeLeftLBL: UILabel!
    @IBOutlet weak var backIMG: UIImageView!
    @IBOutlet weak var bellBTN: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(item: IslamicCalendarModel, isFirst: Bool, titleTxt: String, eventStatus: Bool){
        englishDateLBL.text = "\(item.englishDay) \n \(item.englishMonthStr.prefix(3))"
        islamicDateLBL.text = "\(item.islamicDay) \(item.islamicMonthStr), \(item.islamicYear)"
        
        eventNameLBL.text = titleTxt
        timeLeftLBL.text = item.diffInDays == 0 ? "Today" : "\(item.diffInDays) day/s"
        
        if isFirst {
            backIMG.image = #imageLiteral(resourceName: "IClite-blue-icon")
            englishDateLBL.textColor = #colorLiteral(red: 0.1156475022, green: 0.2083662748, blue: 0.4619608521, alpha: 1)
        }else{
            backIMG.image = #imageLiteral(resourceName: "ICdark-blue-icon")
            englishDateLBL.textColor = .white
        }
        
        if eventStatus == true {
            bellBTN.setImage(#imageLiteral(resourceName: "verifiedIcon"), for: .normal)
        }else{
            bellBTN.setImage(#imageLiteral(resourceName: "ICbell-icon"), for: .normal)
        }
    }
}
