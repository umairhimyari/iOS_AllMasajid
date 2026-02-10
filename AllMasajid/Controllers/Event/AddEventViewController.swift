//
//  AddEventViewController.swift
//  AllMasajid
//
//  Created by Malik Javed Iqbal on 04/04/2020.
//  Copyright © 2020 Shahriyar Memon. All rights reserved.
//

import UIKit
import SwiftValidator
import SafariServices
import PKHUD
import CoreLocation
import SwiftyJSON

class AddEventViewController: UIViewController,ValidationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, TryAgainProtocol, GoBackProtocol {
    
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tvMessageFromHost: UITextView!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtWebsite: UITextField!
    @IBOutlet weak var txtOrganizationName: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var imageStatusLabel: UILabel!
    @IBOutlet weak var flyerUploadLBL: UILabel!
    
    let pickerController = UIImagePickerController()
    var eventDate = Date()
    var eventTime = Date()
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let validator = Validator()
    var imageAttachment : UIImage?
    
    var imageData: Data?
    
    var masjidID = ""
    var masjidLong = ""
    var masjigLat = ""
    var masjidName = ""
    
    var checkScreen = ""
    
    var selectedMasjid: MasjidItem?
    var masjidReceived: MyMasajidModel?
    
    var myLongitude = ""
    var myLatitude = ""
    
    var masjidArray : [MasjidItem] = [] //MasajidItem
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDatePicker()
        setupValidator()
        setupInitials()
        createPickerView()
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
    
    @IBAction func submitEvent(_ sender: UIButton) {
        if txtWebsite.text!.isValidUrl(){
            if txtEmail.text!.isValidEmail(){
                validator.validate(self)
            }else{
                HUD.flash(.label("Please Enter Valid Email"), delay: 0.8)
            }
        }else{
            HUD.flash(.label("Please Enter Valid Website Link"), delay: 0.8)
        }
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    func validationSuccessful() {
     
        successValidation()
        
        if checkScreen == "myMasajid" {
            
            masjidName = masjidReceived?.name ?? ""
            masjidID = masjidReceived?.google_masajid_id ?? ""
            masjigLat = masjidReceived?.lat ?? ""
            masjidLong = masjidReceived?.long ?? ""
            
        }else{
            masjidName = selectedMasjid?.name ?? ""
            masjidID = selectedMasjid?.id ?? ""
            masjigLat = "\(selectedMasjid?.location.coordinate.latitude ?? 0.0)"
            masjidLong = "\(selectedMasjid?.location.coordinate.longitude ?? 0.0)"
        }
        
        addToMyMasjaid()
    }
    
    func tryAgain() {
        locationSettings()
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddEventViewController: ThreeDotProtocol {
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "events"
        vc.titleStr = "Events"
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
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension AddEventViewController {
    
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

extension AddEventViewController{
    
    func addToMyMasjaid(){
        HUD.show(.progress)
        
        var locationToSend = ""
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: masjigLat.toDouble() ?? 0.0, longitude: masjidLong.toDouble() ?? 0.0)) { (places, error) in
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
}

extension AddEventViewController {
    
    func networkHitAddMasjid(location: String){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        let parameters = ["google_masajid_id": "\(masjidID)",
            "name": "\(masjidName)",
            "lat": "\(masjigLat)",
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


extension AddEventViewController {
    
    func networkHit(){
                
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let eventDateString = formatter.string(from: eventDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let eventTimeString = timeFormatter.string(from: eventTime)

        let description = tvDescription.text == "Enter your description here..." ? " " : tvDescription.text
        let msgFromHost = tvMessageFromHost.text == "Enter your message here..." ? " " : tvMessageFromHost.text

        let parameters = [
           "google_masajid_id": "\(masjidID)",
           "title": "\(txtTitle.text ?? "")",
           "description": "\(description ?? " ")",
           "email": "\(txtEmail.text ?? "")",
           "address": "\(txtAddress.text ?? "")",
           "contact":"\(txtPhoneNumber.text ?? "")",
           "date": "\(eventDateString)",
           "time": "\(eventTimeString)",
           "link": "\(txtWebsite.text ?? "")",
           "message": "\(msgFromHost ?? " ")"
        ]
        
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
        if let imageData = imageData{
//            if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
                APIRequestUtil.AddMasjidEvent(parameters: parameters, headers: httpHeaders, imageData: imageData, fileName: "\(txtPhoneNumber.text ?? "")image\(txtTitle.text ?? "")", completion: APIRequestCompleted)
//            }else{
//                APIRequestUtil.AddMasjidEvent(parameters: parameters, headers: [:], imageData: imageData, fileName: "\(txtPhoneNumber.text ?? "")image\(txtTitle.text ?? "")", completion: APIRequestCompleted)
//            }
        }else{
//            if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
                APIRequestUtil.AddMasjidEventWithoutImage(parameters: parameters, headers: httpHeaders, completion: APIRequestCompleted)
//            }else{
//                APIRequestUtil.AddMasjidEventWithoutImage(parameters: parameters, headers: [:], completion: APIRequestCompleted)
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
                vc.text = "Dear User, Your request for the event has been submitted successfully. You can verify your event at  Event verification.\nFor any Query/information, please contact:\n events@allmasajid.com."
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

extension AddEventViewController: CLLocationManagerDelegate{
    
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

extension AddEventViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func createPickerView() {
       let pickerView = UIPickerView()
       pickerView.delegate = self
       txtOrganizationName.inputView = pickerView
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
       let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       txtOrganizationName.inputAccessoryView = toolBar
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
        txtOrganizationName.text = selectedMasjid?.name
        txtAddress.text = selectedMasjid?.address
    }
}

extension AddEventViewController{
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        
        self.btnUpload.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.btnUpload.layer.borderWidth = 1.0
        
        tvDescription.delegate = self
        tvMessageFromHost.delegate = self
        
        txtEmail.text = userEmail
        
        tvDescription.text = "Enter your description here..."
        tvDescription.textColor = UIColor.lightGray
        
        tvMessageFromHost.text = "Enter your message here..."
        tvMessageFromHost.textColor = UIColor.lightGray
        
        imageStatusLabel.isHidden = true
        
        self.hideKeyboardWhenTappedAround()
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        if checkScreen == "nearby"{
            txtOrganizationName.text = selectedMasjid?.name
            txtOrganizationName.isEnabled = false
            
        }else if checkScreen == "myMasajid"{
            txtOrganizationName.text = masjidReceived?.name
            txtOrganizationName.isEnabled = false
        }
        
        locationSettings()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func setupValidator(){
        validator.registerField(txtTitle, rules: [RequiredRule()])
        validator.registerField(txtEmail, rules: [RequiredRule()])
        validator.registerField(txtDate, rules: [RequiredRule()])
        validator.registerField(txtTime, rules: [RequiredRule()])
        validator.registerField(txtAddress, rules: [RequiredRule()])
        validator.registerField(txtWebsite, rules: [RequiredRule()])
        validator.registerField(txtPhoneNumber, rules: [RequiredRule()])
        validator.registerField(txtOrganizationName, rules: [RequiredRule()])
    }
    
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
        
        txtOrganizationName.layer.borderColor = UIColor.lightGray.cgColor
        txtOrganizationName.layer.borderWidth = 0.25
        
        txtDate.layer.borderColor = UIColor.lightGray.cgColor
        txtDate.layer.borderWidth = 0.25
        
        txtTime.layer.borderColor = UIColor.lightGray.cgColor
        txtTime.layer.borderWidth = 0.25
        
        txtAddress.layer.borderColor = UIColor.lightGray.cgColor
        txtAddress.layer.borderWidth = 0.25
        
        txtPhoneNumber.layer.borderColor = UIColor.lightGray.cgColor
        txtPhoneNumber.layer.borderWidth = 0.25
        
        txtWebsite.layer.borderColor = UIColor.lightGray.cgColor
        txtWebsite.layer.borderWidth = 0.25
        
        txtEmail.layer.borderColor = UIColor.lightGray.cgColor
        txtEmail.layer.borderWidth = 0.25
        
        tvMessageFromHost.layer.borderColor = UIColor.lightGray.cgColor
        tvMessageFromHost.layer.borderWidth = 0.25
        
        tvDescription.layer.borderColor = UIColor.lightGray.cgColor
        tvDescription.layer.borderWidth = 0.25
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            
            if textView == tvMessageFromHost{
                textView.text = "Enter your message here..."
            }else{
                textView.text = "Enter your description here..."
            }
            
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AddEventViewController {
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
            flyerUploadLBL.text = "Flyer Uploaded"
        }
    }
}

extension AddEventViewController {
    
    func showDatePicker(){
        datePicker.datePickerMode = .date
        timePicker.datePickerMode = .time
        
        if #available(iOS 14.0, *){
            datePicker.preferredDatePickerStyle = .wheels
            timePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
    
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
    
        txtDate.inputAccessoryView = toolbar
        txtDate.inputView = datePicker
    

        let toolbarTime = UIToolbar();
        toolbarTime.sizeToFit()
        let doneTimeButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donetimePicker))
        let spaceTimeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelTimeButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(canceltimePicker))
        toolbarTime.setItems([doneTimeButton,spaceTimeButton,cancelTimeButton], animated: false)
        
        txtTime.inputAccessoryView = toolbarTime
        txtTime.inputView = timePicker
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        eventDate = datePicker.date
        txtDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func donetimePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        txtTime.text = formatter.string(from: timePicker.date)
        eventTime = timePicker.date
        self.view.endEditing(true)
    }
    
    @objc func canceltimePicker(){
        self.view.endEditing(true)
    }
}
