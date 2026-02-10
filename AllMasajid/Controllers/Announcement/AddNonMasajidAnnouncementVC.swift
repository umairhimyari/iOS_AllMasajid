//
//  AddNonMasajidAnnouncementVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 13/03/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import SwiftValidator
import SafariServices
import CoreLocation
import PKHUD
import SwiftyJSON
import GooglePlaces

class AddNonMasajidAnnouncementVC: UIViewController, ValidationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ThreeDotProtocol, GoBackProtocol {
   
    let pickerController = UIImagePickerController()
    var eventDate = Date()
    var eventTime = Date()
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let validator = Validator()
    var imageAttachment : UIImage?
    
    var imageData: Data?
    
    var selectedPlace = MasjidItem()
    var selectedCity = MasjidItem()
    
    @IBOutlet weak var txtCityName: UITextField!
    @IBOutlet weak var txtOrganizationName: UITextField!
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
    
    @IBAction func cityNamePressed(_ sender: UIButton) {
        autocompleteClicked()
    }
    
    @IBAction func orgNamePressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadOrganizationsScreen()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AddNonMasajidAnnouncementVC: SelectOrganizationProtocol {
    
    func selectOrg(item: MasjidItem) {
        selectedPlace = item
        txtOrganizationName.text = selectedPlace.name
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension AddNonMasajidAnnouncementVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        networkHitCityFromLongLat(long: "\(place.coordinate.longitude)", lat: "\(place.coordinate.latitude)")
        dismiss(animated: true, completion: nil)
    }
    
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func autocompleteClicked() {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
//         Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:  UInt64(UInt(GMSPlaceField.all.rawValue)))
        
        autocompleteController.placeFields = fields

        autocompleteController.tableCellBackgroundColor = UIColor(red:0.03, green:0.27, blue:0.45, alpha:1.0)
        autocompleteController.navigationController?.navigationBar.barTintColor =  UIColor(red:0.03, green:0.27, blue:0.45, alpha:1.0)

        autocompleteController.primaryTextColor = .lightText
        autocompleteController.secondaryTextColor = .lightText
        autocompleteController.primaryTextHighlightColor = .white
        
        self.present(autocompleteController, animated: true, completion: nil)
    }

    // MARK:- Handle GMSAutocompleteViewController errors.
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print(error.localizedDescription)
    }
}

extension AddNonMasajidAnnouncementVC {
    
    func networkHitGetCity(city: String){
        HUD.show(.progress)
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?key=\(Secrets.googleMapsAPIKey)&components=administrative_area:\(city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        APIRequestUtil.GetGoogleCityName(myURL: url, completion: APIRequestCityCompleted)
    }
    
    fileprivate func APIRequestCityCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            let results = json["results"].arrayValue
            if results.count > 0 {
                let address_components = results[0]["address_components"].arrayValue
                
                var cityFound = false
                if address_components.count > 0 {
                    for i in 0..<address_components.count {
                        let types = address_components[i]["types"].arrayValue
                        if types.contains("administrative_area_level_2"){
                            cityFound = true
                            selectedCity.name = address_components[i]["long_name"].stringValue
                            self.txtCityName.text = selectedCity.name
                            break
                        }
                    }
                    
                    if cityFound != true {
                        selectedCity.name = address_components[0]["long_name"].stringValue
                        self.txtCityName.text = selectedCity.name
                    }
                }
                
                
                let geometry = results[0]["geometry"]
                let location = geometry["location"]
                let myLoc = CLLocation(latitude: location["lat"].double ?? 0, longitude: location["lng"].double ?? 0)
                selectedCity.location = myLoc
                selectedCity.id = results[0]["place_id"].stringValue
            }
            
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}


extension AddNonMasajidAnnouncementVC {
    
    func networkHitCityFromLongLat(long: String, lat: String){
        HUD.show(.progress)
        
        APIRequestUtil.GetCityNameFromLongLat(long: long, lat: lat, completion: APIRequestCityFromLongLatCompleted)
    }
    
    fileprivate func APIRequestCityFromLongLatCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            
            let results = json["results"].arrayValue
            if results.count > 0 {
                let address_components = results[0]["address_components"].arrayValue
                var cityFound = false
                if address_components.count > 0 {
                    for i in 0..<address_components.count {
                        let types = address_components[i]["types"].arrayValue
                        if types.contains("administrative_area_level_2"){
                            cityFound = true
                            self.networkHitGetCity(city: address_components[i]["long_name"].stringValue)
                            break
                        }
                    }
                    
                    if cityFound != true {
                        self.networkHitGetCity(city: address_components[0]["long_name"].stringValue)
                    }
                }
            }
            
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}

extension AddNonMasajidAnnouncementVC {
    
    func validationSuccessful() {
        successValidation()
        networkHit()
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

extension AddNonMasajidAnnouncementVC {
    
    func networkHit(){
                
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        let description = tvDescription.text == "Enter your Description here..." ? "" : tvDescription.text!
        
        let parameters = [
            "city_id": "\(selectedCity.id)",
            "city name": selectedCity.name,
            "city_latitude": "\(selectedCity.location.coordinate.latitude)",
            "city_longitude": "\(selectedCity.location.coordinate.longitude)",
            "place_id": selectedPlace.id,
            "place_name": selectedPlace.name,
            "place_latitude": "\(selectedPlace.location.coordinate.latitude)",
            "place_longitude": "\(selectedPlace.location.coordinate.longitude)",
            "title": "\(txtTitle.text ?? "")",
            "description": "\(description)",
            "contact":"\(txtPhoneNumber.text ?? "")",
            "email": "\(txtEmail.text ?? "")",
            "place_address": "\(selectedPlace.address)"
        ]
        print(parameters)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        
        if let imageData = imageData{
//            if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
                APIRequestUtil.AddNonMasjidAnnouncement(parameters: parameters, headers: httpHeaders, imageData: imageData, fileName: "\(txtPhoneNumber.text ?? "")image\(txtTitle.text ?? "")", completion: APIRequestCompleted)
//            }else{
//                APIRequestUtil.AddNonMasjidAnnouncement(parameters: parameters, headers: [:], imageData: imageData, fileName: "\(txtPhoneNumber.text ?? "")image\(txtTitle.text ?? "")", completion: APIRequestCompleted)
//            }
            
        }else{
//            if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
                APIRequestUtil.AddNonMasjidAnnouncementWithoutImage(parameters: parameters, headers: httpHeaders, completion: APIRequestCompleted)
//            }else{
//                APIRequestUtil.AddNonMasjidAnnouncementWithoutImage(parameters: parameters, headers: [:], completion: APIRequestCompleted)
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

extension AddNonMasajidAnnouncementVC {
    
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

extension AddNonMasajidAnnouncementVC{
    
    func setupValidator(){
        validator.registerField(txtTitle, rules: [RequiredRule()])
        validator.registerField(txtPhoneNumber, rules: [RequiredRule()])
        validator.registerField(txtEmail, rules: [RequiredRule()])
        validator.registerField(txtOrganizationName, rules: [RequiredRule()])
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

extension AddNonMasajidAnnouncementVC{
    
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
        
        txtPhoneNumber.layer.borderColor = UIColor.lightGray.cgColor
        txtPhoneNumber.layer.borderWidth = 0.25
        
        txtEmail.layer.borderColor = UIColor.lightGray.cgColor
        txtEmail.layer.borderWidth = 0.25
        
        tvDescription.layer.borderColor = UIColor.lightGray.cgColor
        tvDescription.layer.borderWidth = 0.25
    }
}
