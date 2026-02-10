//
//  EditProfileVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 07/08/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

class EditProfileVC: UIViewController {
    
    var skillsArray = [SkillsModel]()
    var selectedSkill: SkillsModel?
    
    var skillName = ""
    var skillID = 0

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var skillTF: UITextField!
    @IBOutlet weak var skillDisplayTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        networkHit()
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        if emailTF.text!.isValidEmail(){
            if firstNameTF.text == "" || lastNameTF.text == "" || emailTF.text == ""{
                HUD.flash(.label("Please Enter Complete Details First"), delay: 0.8)
            }else{
                if skillID == 1 && skillDisplayTF.text == ""{
                    HUD.flash(.label("Please enter your profession name"), delay: 0.8)
                }else{
                    networkHitEditProfile()
                }
            }
        }else{
            HUD.flash(.label("Please Enter Valid Email"), delay: 0.8)
        }
        
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditProfileVC{
    
    func networkHit(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.GetProfile(headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let first_name = json["first_name"].stringValue
            let last_name = json["last_name"].stringValue
            let email = json["email"].stringValue
            let user_profile = json["user_profile"]
            let contact = user_profile["contact"].stringValue            
            let skills = user_profile["skills"].stringValue
            
            mobileTF.text = contact
            firstNameTF.text = first_name
            lastNameTF.text = last_name
            emailTF.text = email
            skillTF.text = skills
            
            networkHitSkills()
        }else{
            HUD.hide()
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension EditProfileVC{
    
    func networkHitEditProfile(){
        HUD.show(.progress)
        
        var parameters: [String:String] = [:]
        if skillID == 0 {
            parameters = ["first_name": "\(firstNameTF.text!)",
                            "last_name": "\(lastNameTF.text!)",
                            "email": "\(emailTF.text!)",
                            "contact": "\(mobileTF.text!)"
            ]
        }else if skillID == 1{
            parameters = ["first_name": "\(firstNameTF.text!)",
                            "last_name": "\(lastNameTF.text!)",
                            "email": "\(emailTF.text!)",
                            "contact": "\(mobileTF.text!)",
                            "skill_name": "\(skillDisplayTF.text!)",
                            "skill_id": "\(skillID)"
            ]
        }else{
            parameters = ["first_name": "\(firstNameTF.text!)",
                            "last_name": "\(lastNameTF.text!)",
                            "email": "\(emailTF.text!)",
                            "contact": "\(mobileTF.text!)",
                            "skill_name": "\(skillName)",
                            "skill_id": "\(skillID)"
            ]
        }
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
        print(parameters)
        APIRequestUtil.EditProfile(parameters: parameters, headers: httpHeaders, completion: APIRequestEditProfileCompleted)
    }
    
    fileprivate func APIRequestEditProfileCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key
            if firstResponseKey == "error"{
                let error = json["error"].stringValue
                HUD.flash(.labeledError(title: "Error", subtitle: error), delay: 0.7)
            }else{
                HUD.flash(.success, delay: 0.7){finished in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}


extension EditProfileVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHitSkills(){
        APIRequestUtil.GetSkillList(headers: [:], completion: APIRequestSkillsCompleted)
    }
    
    fileprivate func APIRequestSkillsCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            skillsArray.removeAll()
            for i in 0..<json.count{
                let model = SkillsModel(fromJson: json[i])
                skillsArray.append(model)
            }
            
            createPickerView()
            HUD.hide()
        }else{
            HUD.hide()
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}


extension EditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func createPickerView() {
       let pickerView = UIPickerView()
       pickerView.delegate = self
       skillTF.inputView = pickerView
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
       let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       skillTF.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return skillsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return skillsArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSkill = skillsArray[row]
        skillTF.text = selectedSkill?.name
        skillName = selectedSkill?.name ?? ""
        skillID = selectedSkill?.id ?? 0
        
        if skillID == 1 {
            skillDisplayTF.isHidden = false
        }else{
            skillDisplayTF.isHidden = true
        }
    }
}
