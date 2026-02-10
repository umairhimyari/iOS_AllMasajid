//
//  DisplayIqamahTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/11/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class DisplayIqamahTVC: UITableViewCell {

    @IBOutlet weak var backview: UIView!
    @IBOutlet weak var dateLBL: UILabel!
    
    @IBOutlet weak var fajrLBL: UILabel!
    @IBOutlet weak var duhrLBL: UILabel!
    @IBOutlet weak var asrLBL: UILabel!
    @IBOutlet weak var maghribLBL: UILabel!
    @IBOutlet weak var ishaLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(item: DisplayIqamahModel){
        dateLBL.text = item.date == "" ? "-": item.date
        fajrLBL.text = item.fajr == "" ? "-": item.fajr
        duhrLBL.text = item.duhr == "" ? "-": item.duhr
        asrLBL.text = item.asr == "" ? "-": item.asr
        maghribLBL.text = item.maghrib == "" ? "-": "\(item.maghrib) mins"
        ishaLBL.text = item.isha == "" ? "-": item.isha
        
        if item.todayStatus == true{
            backview.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        }else{
            backview.backgroundColor = #colorLiteral(red: 0.06627069414, green: 0.01220263448, blue: 0.2478573024, alpha: 1)
        }
    }
    
}
