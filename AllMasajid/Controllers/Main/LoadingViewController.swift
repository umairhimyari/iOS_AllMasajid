//
//  LoadingViewController.swift
//  AllMasajid
//
//  Created by Malik Javed Iqbal on 13/01/2020.
//  Copyright © 2020 Shahriyar Memon. All rights reserved.
//

import UIKit
import PKHUD

class LoadingViewController: UIViewController, LocationFetchDelegate{

    weak var reloadDelegate: ReloadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.shared.locFetchDelegate = self
        LocationManager.shared.requestLocation()
        
    }
    
    func locationFetched(_ succes: Bool) {
        
        self.reloadDelegate?.dataFetched(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
