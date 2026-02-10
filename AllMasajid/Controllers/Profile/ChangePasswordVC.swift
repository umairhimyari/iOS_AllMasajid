//
//  ChangePasswordVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 27/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var retypePasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        if oldPasswordTF.text != "" && newPasswordTF.text != "" && retypePasswordTF.text != "" {
            if newPasswordTF.text == retypePasswordTF.text{
                networkHit()
            }else{
                HUD.flash(.label("Password Doesn't Match"), delay: 0.7)
            }
        }else{
            HUD.flash(.label("Please Enter Complete Details"), delay: 0.7)
        }
    }
    
    func setupInitials(){
        submitBtn.cornerRadius = 17.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {

        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension ChangePasswordVC{
    
    func networkHit(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        let parameters = ["current_password": "\(oldPasswordTF.text!)",
                        "new_password": "\(newPasswordTF.text!)",
                        "confirm_password": "\(retypePasswordTF.text!)"
        ]
        APIRequestUtil.ChangePassword(parameters: parameters, headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error"{
                let error = json["error"].stringValue
                HUD.flash(.labeledError(title: "Error", subtitle: error), delay: 0.7)
            }else if firstResponseKey == "message"{
                HUD.flash(.success, delay: 0.7){finished in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
