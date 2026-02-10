//
//  MuslimDirectoyHomeVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class MuslimDirectoyHomeVC: UIViewController {

    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func businessBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadMuslimDirectoryBusinessScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
