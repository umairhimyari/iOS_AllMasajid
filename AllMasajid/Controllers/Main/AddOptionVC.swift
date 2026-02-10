//
//  AddOptionVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 11/03/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class AddOptionVC: UIViewController {

    var screen = ""
    var delegate: PerformActionProtocol?
    
    @IBOutlet weak var masjidBTN: UIButton!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var nonMasjidBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        masjidBTN.setTitle("Add Masajid \(screen)", for: .normal)
        nonMasjidBTN.setTitle("Add Non-Masajid \(screen)", for: .normal)
        
        let blackViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackViewTap(_:)))
        blackView.addGestureRecognizer(blackViewTap)
        
    }
    
    @IBAction func addMasjidPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: false) {
                self.delegate?.addMasajidPressed()
            }
        }
    }
    
    @IBAction func addNonMasjidPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: false) {
                self.delegate?.addNonMasajidPressed()
            }
        }
    }
    
    @objc func handleBlackViewTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: false, completion: nil)
    }
}
