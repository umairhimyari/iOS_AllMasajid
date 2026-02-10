//
//  ContributeWithSkillsVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/08/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import Alamofire
import SafariServices

class ContributeWithSkillsVC: UIViewController, GoBackProtocol {

    var skillsArray = [SkillsModel]()
    var selectedSkill: SkillsModel?
    var skillID = 0
    
    var selectedTime = ""
    var myLat = ""
    var myLong = ""
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var skillTF: UITextField!
    @IBOutlet weak var skillNameTF: UITextField!
    @IBOutlet weak var bioTV: UITextView!
    @IBOutlet weak var descriptionTV: UITextView!
    
    @IBOutlet weak var morningImage: UIImageView!
    @IBOutlet weak var morningLabel: UILabel!
    @IBOutlet weak var morningView: UIView!
    
    @IBOutlet weak var eveningImage: UIImageView!
    @IBOutlet weak var eveningLabel: UILabel!
    @IBOutlet weak var eveningView: UIView!
    
    @IBOutlet weak var nightImage: UIImageView!
    @IBOutlet weak var nightLabel: UILabel!
    @IBOutlet weak var nightView: UIView!
    
    @IBOutlet weak var submitBtnView: UIView!
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
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContributeWithSkillsVC{
    
    func networkHit(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.GetProfile(headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let first_name = json["first_name"].stringValue
            let last_name = json["last_name"].stringValue
            let email = json["email"].stringValue
            
            let user_profile = json["user_profile"]
            
            let skills = user_profile["skills"].stringValue
            skillID = user_profile["skills_id"].intValue
            let skill = user_profile["skill"]
            let skillOriginalName = skill["display_name"].stringValue
            
            let contact = user_profile["contact"].stringValue
                     
            nameTF.text = "\(first_name.capitalized) \(last_name.capitalized)"
            emailTF.text = email
            
            if skillID == 1 {
                skillNameTF.isEnabled = true
            }
            skillTF.text = skillOriginalName
            skillNameTF.text = skills
            phoneTF.text = contact
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension ContributeWithSkillsVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHitSkills()
    }
    
    func networkHitSkills(){
        HUD.show(.progress)
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

extension ContributeWithSkillsVC{
    
    func networkHitSubmit(){
        
        HUD.show(.progress)
        
        let desc = descriptionTV.text == "Note" ? "" : descriptionTV.text ?? ""
        let bio = bioTV.text == "Tell us about yourself" ? "" : bioTV.text ?? ""
        
        let parameters = ["name": "\(nameTF.text!)",
                          "email": "\(emailTF.text!)",
                          "lat": "\(myLat)",
                          "long": "\(myLong)",
                          "time_flag": "\(selectedTime)",
                          "skills_id": "\(skillID)",
                          "description": "\(desc)",
                          "phone": "\(phoneTF.text!)",
                          "bio": "\(bio)",
                          "skills": "\(skillNameTF.text!)"
        ]
        print(parameters)
//        var headers: HTTPHeaders = [:]
//
//        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
//            headers = ["Authorization": "Bearer \(myToken)"]
//        }
        APIRequestUtil.ContributeSkills(parameters: parameters, headers: httpHeaders, completion: APIRequestSubmitCompleted)
    }
    
    fileprivate func APIRequestSubmitCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            HUD.hide()
            
            let vc = UIStoryboard().LoadVerificationSuccessScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }else{
            HUD.hide()
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension ContributeWithSkillsVC: ThreeDotProtocol {
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "contribute"
        vc.titleStr = "Contribute"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpBtnPressed(){
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func refreshBtnPressed() {
        print("Do nothing")
    }
    
    func shareBtnPressed() {
        print("Do nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension ContributeWithSkillsVC {
    
    func setupInitials(){
        setGestures()
        morning()
        
        bioTV.delegate = self
        descriptionTV.delegate = self
        
        bioTV.text = "Tell us about yourself"
        bioTV.textColor = UIColor.lightGray
        
        descriptionTV.text = "Note"
        descriptionTV.textColor = UIColor.lightGray
        
        do {
            if let data2 = UserDefaults.standard.data(forKey: "savedLocation"),
                  let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data2) as? SavedLocation {
                print(SelectedPlace.name)
                myLat = "\(SelectedPlace.latitude)"
                myLong = "\(SelectedPlace.longitude)"
            }
        } catch { print(error) }
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            networkHit()
        }
        
        networkHitSkills()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {

        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    @objc func morningPressed(sender : UITapGestureRecognizer) {
        morning()
    }
    
    @objc func eveningPressed(sender : UITapGestureRecognizer) {
        evening()
    }
    
    @objc func nightPressed(sender : UITapGestureRecognizer) {
        night()
    }
    
    @objc func submitPressed(sender: UITapGestureRecognizer) {
        if emailTF.text!.isValidEmail(){
            if emailTF.text! == "" || nameTF.text! == "" || phoneTF.text! == "" || skillID == 0 || skillNameTF.text! == "" {
                HUD.flash(.label("Please enter complete details to continue"), delay: 0.8)
            }else{
                networkHitSubmit()
            }
        }else{
            HUD.flash(.label("Please Enter Valid Email"), delay: 0.8)
        }
        
    }
}

extension ContributeWithSkillsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        skillID = selectedSkill?.id ?? 0
        
        if skillID == 1 {
            skillNameTF.text = ""
            skillNameTF.isEnabled = true
        }else{
            skillNameTF.text = selectedSkill?.name
            skillNameTF.isEnabled = false
        }
    }
}

extension ContributeWithSkillsVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == bioTV && textView.text.isEmpty {
            textView.text = "Tell us about yourself"
            textView.textColor = UIColor.lightGray
        }else if textView == bioTV && textView.text.isEmpty {
            textView.text = "Note"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ContributeWithSkillsVC {
    
    func setGestures(){
        let gestureMorning = UITapGestureRecognizer(target: self, action:  #selector(self.morningPressed))
        self.morningView.addGestureRecognizer(gestureMorning)

        let gestureEvening = UITapGestureRecognizer(target: self, action:  #selector(self.eveningPressed))
        self.eveningView.addGestureRecognizer(gestureEvening)
        
        let gestureNight = UITapGestureRecognizer(target: self, action:  #selector(self.nightPressed))
        self.nightView.addGestureRecognizer(gestureNight)
        
        let submit = UITapGestureRecognizer(target: self, action:  #selector(self.submitPressed))
        self.submitBtnView.addGestureRecognizer(submit)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
    }
    
    func morning(){
        
        selectedTime = "morning"
        
        morningView.backgroundColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
        eveningView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        nightView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        morningImage.image = #imageLiteral(resourceName: "sunWhite")
        eveningImage.image = #imageLiteral(resourceName: "eveningBlue")
        nightImage.image = #imageLiteral(resourceName: "nightBlue")
        
        morningLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        eveningLabel.textColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
        nightLabel.textColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
    }
    
    func evening(){
        
        selectedTime = "evening"
        
        morningView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        eveningView.backgroundColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
        nightView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        morningImage.image = #imageLiteral(resourceName: "sunBlue")
        eveningImage.image = #imageLiteral(resourceName: "eveningWhite")
        nightImage.image = #imageLiteral(resourceName: "nightBlue")
        
        morningLabel.textColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
        eveningLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        nightLabel.textColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
    }
    
    func night(){
                
        selectedTime = "night"
        
        morningView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        eveningView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        nightView.backgroundColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
        
        morningImage.image = #imageLiteral(resourceName: "sunBlue")
        eveningImage.image = #imageLiteral(resourceName: "eveningBlue")
        nightImage.image = #imageLiteral(resourceName: "nightWhite")
        
        morningLabel.textColor = #colorLiteral(red: 0.3952031434, green: 0.6563007236, blue: 0.8216872811, alpha: 1)
        eveningLabel.textColor = #colorLiteral(red: 0.3960784314, green: 0.6549019608, blue: 0.8235294118, alpha: 1)
        nightLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}
