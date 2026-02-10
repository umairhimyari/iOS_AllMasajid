//
//  ProfileVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 25/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class ProfileVC: UIViewController {
    
    var selectedImage: UIImage?
    var imageData: Data?
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var roundingView: UIView!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var verifyMobileBtn: UIButton!
    @IBOutlet weak var verifyEmailBtn: UIButton!
    @IBOutlet weak var professionLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePasswordPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadChangePasswordScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadEditProfileScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logoutBtnPressed(_ sender: UIButton) {
        logoutUser()
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: UIButton) {
        Alert.showWithTwoActions(title: "Alert!", msg: "Are you sure you want to delete your account?", okBtnTitle: "Yes", okBtnAction: {
            self.callDeleteAccount()
        }, cancelBtnTitle: "No") {}
    }
    
    @IBAction func mobileVerifyPressed(_ sender: UIButton) {
        
        if mobileLbl.text != "-"{
            let vc = UIStoryboard().LoadPhoneVerificationScreen()
            vc.phoneNumber = mobileLbl.text!
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            HUD.flash(.label("Please Enter Mobile# First"), delay: 0.6)
        }
        
        /*
        if mobileLbl.text != "-"{
            let vc = UIStoryboard().LoadVerifyOTPScreen()
            vc.emailPhoneCheck = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            HUD.flash(.label("Please Enter Mobile# First"), delay: 0.6)
        }
        */
    }
    
    @IBAction func emailVerifyPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadVerifyOTPScreen()
        vc.emailPhoneCheck = 2
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
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
            
            let email_verification_status = user_profile["email_verification_status"].stringValue
            let contact_verification_status = user_profile["contact_verification_status"].stringValue
            
            let contact = user_profile["contact"].stringValue
                     
            professionLBL.text = skills == "" ? "-" : skills
            mobileLbl.text = contact == "" ? "-" : contact
            
            
            let image = user_profile["image"].stringValue
            
            nameLbl.text = first_name.capitalized + " " + last_name.capitalized
            emailLbl.text = email
            
            if email_verification_status == "1" {
                verifyEmailBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5399764776, blue: 0.8613250852, alpha: 1)
                verifyEmailBtn.setTitle("Verified", for: .normal)
                verifyEmailBtn.isEnabled = false
            }else{
                verifyEmailBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                verifyEmailBtn.setTitle("Verify", for: .normal)
            }
            
            if contact_verification_status == "1" {
                verifyMobileBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5399764776, blue: 0.8613250852, alpha: 1)
                verifyMobileBtn.setTitle("Verified", for: .normal)
                verifyMobileBtn.isEnabled = false
            }else if mobileLbl.text == "-"{
                verifyMobileBtn.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                verifyMobileBtn.setTitle("Verify", for: .normal)
            }else{
                verifyMobileBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                verifyMobileBtn.setTitle("Verify", for: .normal)
            }
            
            profileImage.contentMode = .scaleAspectFill
            if image != ""{
                GetImage.getImage(url: URL(string: image)!, image: profileImage)
            }
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}

extension ProfileVC {
    
    func setupInitials(){
        profileImage.cornerRadius = 55
        roundingView.cornerRadius = 65
        verifyMobileBtn.cornerRadius = 15
        verifyEmailBtn.cornerRadius = 15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
        
        do {
            if let data2 = UserDefaults.standard.data(forKey: "savedLocation"),
                  let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data2) as? SavedLocation {
                print(SelectedPlace.name)
                cityLbl.text = SelectedPlace.name
            }
        } catch { print(error) }
        
        networkHit()
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        userEmail = ""
        
        let vc = UIStoryboard().LoadLandingScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        imageBtn()
    }

    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {

        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}


extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            selectedImage = originalImage
        }else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImage = editedImage
        }

        if let myImage = selectedImage {

            imageData = myImage.jpegData(compressionQuality: 0.5)
            networkHitChangeImage()
        }
    }
}

extension ProfileVC{
    
    func networkHitChangeImage(){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.ChangeProfileImage(headers: httpHeaders, imageData: imageData!, fileName: "\(String(describing: nameLbl.text))", completion: APIRequestChangeImageCompleted)
    }
    
    fileprivate func APIRequestChangeImageCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            profileImage.image = selectedImage
           
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension ProfileVC{
    func callDeleteAccount(){
        HUD.show(.progress)
        APIRequestUtil.DeleteProfile(headers: httpHeaders, completion: callDeleteAccountCompleted)
    }
    
    fileprivate func callDeleteAccountCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            logoutUser()
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
