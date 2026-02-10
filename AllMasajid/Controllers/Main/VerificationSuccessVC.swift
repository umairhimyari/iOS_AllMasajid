//
//  VerificationSuccessVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 22/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class VerificationSuccessVC: UIViewController {

    var text = ""
    var delegate: GoBackProtocol?

    
    @IBOutlet weak var textTF: UILabel!
    @IBOutlet weak var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blackViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackViewTap(_:)))
        blackView.addGestureRecognizer(blackViewTap)
        
        if text != "" {
            textTF.text = text
        }
    }

    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismissVC()
    }
    
    @objc func handleBlackViewTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissVC()
    }
    
    func dismissVC(){
        DispatchQueue.main.async {
            self.dismiss(animated: false) {
                self.delegate?.goBack()
            }
        }
    }
}
