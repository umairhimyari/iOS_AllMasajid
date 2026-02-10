//
//  AddAnnouncementViewController.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/05/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import SwiftValidator
import SafariServices
import CoreLocation
import PKHUD
import SwiftyJSON

class AddAnnouncementViewController: UIViewController, ValidationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ThreeDotProtocol, TryAgainProtocol {
   
    var masjidID = ""
    var masjidLong = ""
    var masjidLat = ""
    var masjidName = ""
    
    var checkScreen = ""
    
    var selectedMasjid: MasjidItem?
    var masjidReceived: MyMasajidModel?
    
    var myLongitude = ""
    var myLatitude = ""
    
    let pickerController = UIImagePickerController()
    let validator = Validator()
    var imageAttachment : UIImage?
    var imageData: Data?
    
    var masjidArray : [MasjidItem] = []
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!
    
    @IBOutlet weak var masjidOrgNameTextField: UITextField!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var imageStatusLabel: UILabel!
    @IBOutlet weak var flyerUploadLBL: UILabel!
    
    @IBOutlet var footerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageStatusLabel.isHidden = true
        tvDescription.delegate = self
        
        tvDescription.text = "Enter your Description here..."
        tvDescription.textColor = UIColor.lightGray
        
        setupValidator()
        createPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()

    }
    
    override func viewDidLayoutSubviews() {
        
        let contentRect: CGRect = self.scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        self.scrollView.contentSize = contentRect.size
    }
    
    @IBAction func uploadPicture(_ sender: UIButton) {
        imageBtn()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitAnnouncementPressed(_ sender: UIButton) {
        
        if txtEmail.text!.isValidEmail(){
            validator.validate(self)
        }else{
            HUD.flash(.label("Please Enter Valid Email"), delay: 0.8)
        }
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func tryAgain() {
        locationSettings()
    }
}

extension AddAnnouncementViewController {
    
    func validationSuccessful() {
     
        successValidation()
        if checkScreen == "myMasajid" {
            
            masjidName = masjidReceived?.name ?? ""
            masjidID = masjidReceived?.google_masajid_id ?? ""
            masjidLat = masjidReceived?.lat ?? ""
            masjidLong = masjidReceived?.long ?? ""
            
        }
        else{
            masjidName = selectedMasjid?.name ?? ""
            masjidID = selectedMasjid?.id ?? ""
            masjidLat = "\(selectedMasjid?.location.coordinate.latitude ?? 0.0)"
            masjidLong = "\(selectedMasjid?.location.coordinate.longitude ?? 0.0)"
        }
        
        addToMyMasjaid()
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "announcement"
        vc.titleStr = "Announcements"
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

extension AddAnnouncementViewController {
    
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
            
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}
 
extension AddAnnouncementViewController: GoBackProtocol{
    
    func addToMyMasjaid(){
        HUD.show(.progress)
        
        var locationToSend = ""
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: masjidLat.toDouble() ?? 0.0, longitude: masjidLong.toDouble() ?? 0.0)) { (places, error) in
            if error == nil{
                if let place = places{
                    let myPlace = "\(place)"
                    if myPlace.contains("@"){
                        let newStr = myPlace.components(separatedBy: "@")
                        locationToSend = newStr[0]
                        if locationToSend.first == "["{
                            locationToSend = String(locationToSend.dropFirst())
                        }
                        self.networkHitAddMasjid(location: locationToSend)
                    }
                }
            }else {
                self.networkHitAddMasjid(location: "")
            }
        }
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddAnnouncementViewController {
    
    func networkHitAddMasjid(location: String){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        let parameters = [
            "google_masajid_id": "\(masjidID)",
            "name": "\(masjidName)",
            "lat": "\(masjidLat)",
            "long": "\(masjidLong)",
            "address": "\(location)"
        ]
        
//        if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.AddMasjid(parameters: parameters, headers: httpHeaders, completion: APIRequestAddMasjidCompleted)
//        }else{
//            APIRequestUtil.AddMasjid(parameters: parameters, headers: [:], completion: APIRequestAddMasjidCompleted)
//        }
    }
    
    fileprivate func APIRequestAddMasjidCompleted(response: Any?, error: Error?) {
        
        if response != nil{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            networkHit()
                        
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}


extension AddAnnouncementViewController {
    
    func networkHit(){
                
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        var description = ""
        if tvDescription.text == "Enter your Description here..."{
            description = ""
        }else{
            description = tvDescription.text
        }
        
        let parameters = [
            "google_masajid_id": "\(masjidID)",
            "title": "\(txtTitle.text ?? "")",
            "description": "\(description)",
            "email": "\(txtEmail.text ?? "")",
            "contact":"\(txtPhoneNumber.text ?? "")"
        ]
        
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
        if let imageData = imageData{
//            if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
                APIRequestUtil.AddMasjidAnnouncement(parameters: parameters, headers: httpHeaders, imageData: imageData, fileName: "\(txtPhoneNumber.text ?? "")image\(txtTitle.text ?? "")", completion: APIRequestCompleted)
//            }else{
//                APIRequestUtil.AddMasjidAnnouncement(parameters: parameters, headers: [:], imageData: imageData, fileName: "\(txtPhoneNumber.text ?? "")image\(txtTitle.text ?? "")", completion: APIRequestCompleted)
//            }
            
        }else{
//            if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
                APIRequestUtil.AddMasjidAnnouncementWithoutImage(parameters: parameters, headers: httpHeaders, completion: APIRequestCompleted)
//            }else{
//                APIRequestUtil.AddMasjidAnnouncementWithoutImage(parameters: parameters, headers: [:], completion: APIRequestCompleted)
//            }
        }
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "message"{

                let vc = UIStoryboard().LoadVerificationSuccessScreen()
                vc.delegate = self
                vc.text = "Dear User, Your request for the announcement has been submitted successfully. Please visit the following announcement verification to verify your announcement.\nFor any Query/information, please contact:\nannouncements@allmasajid.com"
                vc.modalPresentationStyle = .overFullScreen
                self.parent?.present(vc, animated: false, completion: nil)
            }
            
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}

extension AddAnnouncementViewController: CLLocationManagerDelegate{
    
    func locationSettings(){
            
        if UserDefaults.standard.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    
                    self.getNearbyMasjids(loc: myLocation.coordinate)
                }
            } catch { print(error) }
            
//            if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
//                let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
//                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
//
//                self.getNearbyMasjids(loc: myLocation.coordinate)
//            }
        }else if UserDefaults.standard.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.getNearbyMasjids(loc: myLocation.coordinate)
                }
            } catch { print(error) }
            
//
//            if let data = UserDefaults.standard.data(forKey: "savedLocation"),
//                let SelectedPlace = NSKeyedUnarchiver.unarchiveObject(with: data) as? SavedLocation {
//                myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
//                self.getNearbyMasjids(loc: myLocation.coordinate)
//            }
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

extension AddAnnouncementViewController {
    func imageBtn() {
        let Alert = UIAlertController(title: "Attach Image", message: "", preferredStyle: UIAlertController.Style.alert)

        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
         self.takePicture(x: .camera)
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
         self.takePicture(x: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }

        Alert.addAction(cameraAction)
        Alert.addAction(galleryAction)
        Alert.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(Alert, animated: true, completion: nil)
    }
    
    
    func takePicture(x : UIImagePickerController.SourceType){

        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = x
        image.allowsEditing = true

        UIApplication.shared.keyWindow?.rootViewController?.present(image, animated: true){

        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageAttachment = originalImage
        }else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            imageAttachment = editedImage
        }

        if let myImage = imageAttachment {
            imageData = myImage.jpegData(compressionQuality: 0.5)
            imageStatusLabel.isHidden = false
            flyerUploadLBL.text = "Flayer Uploaded"
        }
    }
}


extension AddAnnouncementViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func createPickerView() {
       let pickerView = UIPickerView()
       pickerView.delegate = self
       masjidOrgNameTextField.inputView = pickerView
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
       let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       masjidOrgNameTextField.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return masjidArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return masjidArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMasjid = masjidArray[row]
        masjidOrgNameTextField.text = selectedMasjid?.name
        
    }
}

extension AddAnnouncementViewController{
    
    func setupValidator(){
        validator.registerField(txtTitle, rules: [RequiredRule()])
        validator.registerField(txtPhoneNumber, rules: [RequiredRule()])
        validator.registerField(txtEmail, rules: [RequiredRule()])
        validator.registerField(masjidOrgNameTextField, rules: [RequiredRule()])
    }
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        self.btnUpload.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.btnUpload.layer.borderWidth = 1.0
        
        txtEmail.text = userEmail
        
        self.hideKeyboardWhenTappedAround()
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        if checkScreen == "nearby"{
            masjidOrgNameTextField.text = selectedMasjid?.name
            masjidOrgNameTextField.isEnabled = false
            
        }else if checkScreen == "myMasajid"{
            masjidOrgNameTextField.text = masjidReceived?.name
            masjidOrgNameTextField.isEnabled = false
        }
        
        locationSettings()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = "Enter your Description here..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AddAnnouncementViewController{
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, _) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            field.text = ""
                field.attributedPlaceholder = NSAttributedString(string: "\(field.placeholder ?? "") Required *",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
        }
        HUD.hide()
    }
    
    func successValidation(){
        txtTitle.layer.borderColor = UIColor.lightGray.cgColor
        txtTitle.layer.borderWidth = 0.25
        
        masjidOrgNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        masjidOrgNameTextField.layer.borderWidth = 0.25
        
        txtPhoneNumber.layer.borderColor = UIColor.lightGray.cgColor
        txtPhoneNumber.layer.borderWidth = 0.25
        
        txtEmail.layer.borderColor = UIColor.lightGray.cgColor
        txtEmail.layer.borderWidth = 0.25
        
        tvDescription.layer.borderColor = UIColor.lightGray.cgColor
        tvDescription.layer.borderWidth = 0.25
    }
}
