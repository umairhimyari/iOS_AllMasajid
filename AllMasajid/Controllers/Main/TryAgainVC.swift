//
//  TryAgainVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class TryAgainVC: UIViewController {
    
    var delegate: TryAgainProtocol?

    @IBOutlet weak var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blackViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackViewTap(_:)))
        blackView.addGestureRecognizer(blackViewTap)
    }
    
    @objc func handleBlackViewTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func tryAgainPressed(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false) {
                guard let action = self.delegate else {return}
                action.tryAgain()
            }
        })
    }
}
