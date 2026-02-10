//
//  MDCategoriesCVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class MDCategoriesCVC: UICollectionViewCell {

    @IBOutlet weak var bg1View: UIView!
    @IBOutlet weak var bg2View: UIView!
    
    @IBOutlet weak var titleLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Called")
        setGradient2BG()
    }

    override var isSelected: Bool {
        didSet {
            if isSelected { // Selected cell
                self.bg1View.backgroundColor = .white
                self.bg2View.backgroundColor = .white
                self.bg2View.borderColor = .white
                self.titleLBL.textColor = .black
            } else { // Normal cell
                setGradient2BG()
                self.bg2View.backgroundColor = UIColor(hexString: "0B4574")
                self.bg2View.borderColor = .black
                self.titleLBL.textColor = .white
            }
        }
    }
    
    func setGradient2BG(){
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.bg1View.frame.size.width, height: self.bg1View.frame.size.height)
        gradient.cornerRadius = 22.5
        gradient.masksToBounds = true
        self.bg1View.layer.insertSublayer(gradient, at: 0)
        self.bg1View.layer.masksToBounds = true
    }
}
