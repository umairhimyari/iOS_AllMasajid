//
//  AddDuaRequestVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 04/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import Alamofire
import SafariServices

class AddDuaRequestVC: UIViewController {
    
    var isEdit = false
    var idReceived = 0
    
    var isSecret = 0
    var locationName = ""
    
    var delegate: RefreshProtocol?
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var contactTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var appealTV: UITextView!
    @IBOutlet weak var anonymousLBL: UILabel!
    
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var footerView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        if emailTF.text!.isValidEmail(){
            if userNameTF.text == "" || emailTF.text == "" || titleTF.text == "" || appealTV.text == "Appeal..." || appealTV.text == ""{
                HUD.flash(.label("Please enter complete details to continue"), delay: 0.8)
            }else{
                if isEdit{
                    networkHitEdit()
                }else{
                    networkHit()
                }
            }
        }else{
            HUD.flash(.label("Please Enter Valid Email"), delay: 0.8)
        }
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        if sender.isOn{
            isSecret = 1
            anonymousLBL.text = "Anonymous Posting: ON"
        }else{
            isSecret = 0
            anonymousLBL.text = "Anonymous Posting: OFF"
        }
    }
}

extension AddDuaRequestVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "dua_appeals"
        vc.titleStr = "Dua Appeals"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        print("Do Nothing")
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func favouritesBtnPressed(){
        print("Do nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension AddDuaRequestVC: GoBackProtocol {
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        appealTV.delegate = self
        isEdit ? setupEdit() : setupAdd()
    }
    
    func setupAdd(){
        appealTV.text = "Appeal..."
        appealTV.textColor = UIColor.lightGray
        
        do {
            if let data2 = UserDefaults.standard.data(forKey: "savedLocation"),
                  let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data2) as? SavedLocation {
                locationName = SelectedPlace.name
            }
        } catch { print(error) }
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            networkHitProfile()
        }
    }
    
    func setupEdit(){
        networkHitSingleApeal(id: idReceived)
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func goBack() {
        self.delegate?.refresh()
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddDuaRequestVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Appeal..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AddDuaRequestVC {
    
    func networkHit(){
        HUD.show(.progress)
        
        let appealTxt = appealTV.text == "Appeal..." ? "" : appealTV.text ?? ""
        
        let parameters = ["user_name": "\(userNameTF.text!)",
                          "email": "\(emailTF.text!)",
                          "contact_no": "\(contactTF.text!)",
                          "title": "\(titleTF.text!)",
                          "appeal": appealTxt,
                          "is_secret": "\(isSecret)",
                          "location": locationName
        ]
        
//        var headers: HTTPHeaders = [:]
//        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
//            headers = ["Authorization": "Bearer \(myToken)"]
//        }
        
        APIRequestUtil.SendAppeal(parameters: parameters, headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    func networkHitEdit(){
        
        HUD.show(.progress)
        
        let appealTxt = appealTV.text == "Appeal..." ? "" : appealTV.text ?? ""
//        let headers = ["Authorization": "Bearer \(myToken)"]
        let parameters = ["user_name": "\(userNameTF.text!)",
                          "email": "\(emailTF.text!)",
                          "contact_no": "\(contactTF.text!)",
                          "title": "\(titleTF.text!)",
                          "appeal": appealTxt,
                          "is_secret": "\(isSecret)"
        ]
        APIRequestUtil.EditAppeal(id: idReceived, parameters: parameters, headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            if isEdit{
                HUD.flash(.success, delay: 0.8){finished in
                    self.goBack()
                }
            }else{
                let vc = UIStoryboard().LoadVerificationSuccessScreen()
                vc.delegate = self
                vc.modalPresentationStyle = .overFullScreen
                self.parent?.present(vc, animated: false, completion: nil)
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension AddDuaRequestVC{
    
    func networkHitProfile(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.GetProfile(headers: httpHeaders, completion: APIRequestCompletedProfile)
    }
    
    fileprivate func APIRequestCompletedProfile(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let first_name = json["first_name"].stringValue
            let last_name = json["last_name"].stringValue
            let email = json["email"].stringValue
            
            let user_profile = json["user_profile"]
            let contact = user_profile["contact"].stringValue
                     
            userNameTF.text = "\(first_name.capitalized) \(last_name.capitalized)"
            emailTF.text = email
            contactTF.text = contact
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}


extension AddDuaRequestVC{
    
    func networkHitSingleApeal(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.SingleAppeal(id: id, headers: httpHeaders, completion: APIRequestSingleApealCompleted)
    }
    
    fileprivate func APIRequestSingleApealCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let is_secret = json["is_secret"].intValue
            let email = json["email"].stringValue
            let title = json["title"].stringValue
            let user_name = json["user_name"].stringValue
            let contact_no = json["contact_no"].stringValue
            let appeal = json["appeal"].stringValue
            
            userNameTF.text = user_name
            titleTF.text = title
            emailTF.text = email
            emailTF.isEnabled = false
            contactTF.text = contact_no
            
            if is_secret == 1 {
                isSecret = 1
                anonymousLBL.text = "Anonymous Posting: ON"
                mySwitch.isOn = true
            }else{
                isSecret = 0
                anonymousLBL.text = "Anonymous Posting: OFF"
                mySwitch.isOn = false
            }
            
            if appeal == "" {
                appealTV.text = "Appeal..."
                appealTV.textColor = UIColor.lightGray
            }else{
                appealTV.text = appeal
                appealTV.textColor = UIColor.black
            }
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
