//
//  ContributeWithTimeVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import Alamofire
import CoreLocation
import SafariServices

class ContributeWithTimeVC: UIViewController, GoBackProtocol {

    var masjidPickerView = UIPickerView()
    var pickerView = UIPickerView()
    
    var masjidID = ""
    var masjidArray : [MasjidItem] = []
    
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!
    
    var interestArray = [InterestModel]()
    var selectedInterest: InterestModel?
    var interestID = 0
    
    var selectedTime = ""
    var myLongitude = ""
    var myLatitude = ""
    
    @IBOutlet weak var masjidTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var interestTF: UITextField!
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

extension ContributeWithTimeVC {
    
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
            let contact = user_profile["contact"].stringValue
                     
            nameTF.text = "\(first_name.capitalized) \(last_name.capitalized)"
            emailTF.text = email
            phoneTF.text = contact
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension ContributeWithTimeVC : TryAgainProtocol{
    
    func tryAgain() {
        networkHitInterest()
    }
    
    func networkHitInterest(){
        HUD.show(.progress)
        APIRequestUtil.GetInterestsList(headers: [:], completion: APIRequestInterestsCompleted)
    }
    
    fileprivate func APIRequestInterestsCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            interestArray.removeAll()
            for i in 0..<json.count{
                let model = InterestModel(fromJson: json[i])
                interestArray.append(model)
            }
            
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

extension ContributeWithTimeVC {
    
    func getNearbyMasjids(loc : CLLocationCoordinate2D){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        var unit = ""
        var meters = 0.0
        if defaults.integer(forKey: "Unit") == 0 {
            meters = (Double(nearbyRange[defaults.integer(forKey: "Distance")])!/0.6213) * 1000
            unit = "M"
        }else{
            meters = Double(nearbyRange[defaults.integer(forKey: "Distance")])! * 1000
            unit = "K"
        }
        
        myLongitude = "\(loc.longitude)"
        myLatitude = "\(loc.latitude)"
        
        APIRequestUtil.GetNearByMasajid(latitude: "\(loc.latitude)", longitude: "\(loc.longitude)", radius: "\(meters)", units: "\(unit)", completion: APIRequestNearbyCompleted)
    }
    
    fileprivate func APIRequestNearbyCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            
            let json = JSON(response)
            print(json)
            
            masjidArray.removeAll()
            
            if json.count == 0 {
                Alert.showMsg(title: "No masajid found.", msg: "Sorry could not find any masajid in your area.", btnActionTitle: "Ok")
            }
            self.masjidArray = CommonApiResponse.shared.nearByMasajid(json: json)
            createPickerView()
            
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}

extension ContributeWithTimeVC {
    
    func networkHitSubmit(){
        
        HUD.show(.progress)
        
        let desc = descriptionTV.text == "Note" ? "" : descriptionTV.text ?? ""
        let bio = bioTV.text == "Tell us about yourself" ? "" : bioTV.text ?? ""
                
        let parameters = ["name": "\(nameTF.text!)",
                          "google_masajid_id": "\(masjidID)",
                          "email": "\(emailTF.text!)",
                          "lat": "\(myLatitude)",
                          "long": "\(myLongitude)",
                          "time_flag": "\(selectedTime)",
                          "interest_id": "\(interestID)",
                          "description": "\(desc)",
                          "phone": "\(phoneTF.text!)",
                          "bio": "\(bio)"
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


extension ContributeWithTimeVC: CLLocationManagerDelegate{
    
    func locationSettings(){
            
        if UserDefaults.standard.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    
                    self.getNearbyMasjids(loc: myLocation.coordinate)
                }
            } catch { print(error) }
            
        }else if UserDefaults.standard.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNearbyMasjids(loc: myLocation.coordinate)
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                getNearbyMasjids(loc: myLocation.coordinate)
                
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
        }
    }
    
    func observeLocation(object: LocationManager) {
        objectToObserve = object
        if (objectToObserve.myLocation == nil){
            showLocationAlert()
        }else{
            
            if let location = LocationManager.shared.myLocation{
                self.myLocation = location
            }
            self.getNearbyMasjids(loc: self.myLocation.coordinate)
        }
    }
    
    func showLocationAlert()
    {
        let alertController = UIAlertController(title: "Location Services Off OR No Permission Granted Yet!", message: "Either location services are off OR you did not allow 'My Masajid App' to access your location. Please turn on location services from phone settings for this application or use manual location from application settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                self.navigationController?.popViewController(animated: true)
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ContributeWithTimeVC: ThreeDotProtocol {
    
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

extension ContributeWithTimeVC {
    
    func setupInitials(){
        setGestures()
        morning()
        
        bioTV.delegate = self
        descriptionTV.delegate = self
        
        bioTV.text = "Tell us about yourself"
        bioTV.textColor = UIColor.lightGray
        
        descriptionTV.text = "Note"
        descriptionTV.textColor = UIColor.lightGray
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            networkHit()
        }
        
        networkHitInterest()
        locationSettings()
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
            if emailTF.text! == "" || nameTF.text! == "" || phoneTF.text! == "" || interestTF.text! == "" {
                HUD.flash(.label("Please enter complete details to continue"), delay: 0.8)
            }else{
                networkHitSubmit()
            }
        }else{
            HUD.flash(.label("Please Enter Valid Email"), delay: 0.8)
        }
    }
}

extension ContributeWithTimeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func createPickerView() {
        
        pickerView.delegate = self
        interestTF.inputView = pickerView
        
        masjidPickerView.delegate = self
        masjidTF.inputView = masjidPickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        interestTF.inputAccessoryView = toolBar
        masjidTF.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == masjidPickerView {
            return masjidArray.count
        }else{
            return interestArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == masjidPickerView {
            return masjidArray[row].name
        }else{
            return interestArray[row].name
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == masjidPickerView {
            let selectedMasjid = masjidArray[row]
            masjidID = selectedMasjid.id
            masjidTF.text = selectedMasjid.name
        }else{
            selectedInterest = interestArray[row]
            interestTF.text = selectedInterest?.name
            interestID = selectedInterest?.id ?? 0
        }
    }
}

extension ContributeWithTimeVC: UITextViewDelegate{
    
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

extension ContributeWithTimeVC {
    
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
