//
//  SimpleTextTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/09/2022.
//  Copyright © 2022 allMasajid. All rights reserved.
//

import UIKit

class SimpleTextTVC: UITableViewCell {

    @IBOutlet weak var htmlTxtLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(txt: String) {
        htmlTxtLBL.attributedText = txt.convertHtmlToAttributedStringWithCSS(font: .systemFont(ofSize: 14, weight: .regular), csscolor: "#FFFFFF", lineheight: 2, csstextalign: "justify")
    }
}
