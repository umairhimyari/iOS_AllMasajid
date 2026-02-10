//
//  NoInternetVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 15/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class NoInternetVC: UIViewController {

    @IBOutlet weak var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blackViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackViewTap(_:)))
        blackView.addGestureRecognizer(blackViewTap)
    }

    @IBAction func closeBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func handleBlackViewTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
