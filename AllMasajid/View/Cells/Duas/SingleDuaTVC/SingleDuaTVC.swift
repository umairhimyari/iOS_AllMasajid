//
//  SingleDuaTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/11/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class SingleDuaTVC: UITableViewCell {

    @IBOutlet weak var duaTitleLBL: UILabel!
    @IBOutlet weak var duaLBL: UILabel!
    @IBOutlet weak var translation2LBL: UILabel!
    @IBOutlet weak var translation2TitleLBL: UILabel!
    @IBOutlet weak var translationLBL: UILabel!
    @IBOutlet weak var referenceLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureHadithCell(item: HadithModel) {
        translation2LBL.isHidden = true
        translation2TitleLBL.isHidden = true
        duaTitleLBL.textColor = UIColor(hexString: "A1D7FF")
        duaTitleLBL.text = item.title == "" ? "-": item.title
        duaLBL.text = item.hadithAr == "" ? "-": item.hadithAr
        translationLBL.text = item.translationEn == "" ? "-": item.translationEn
        referenceLBL.text = item.reference == "" ? "[ No Reference ]": "[\(item.reference)]"
    }
    
}
