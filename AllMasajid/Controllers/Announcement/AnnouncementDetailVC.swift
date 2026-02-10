//
//  AnnouncementDetailVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/06/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import MessageUI
import SwiftyJSON

class AnnouncementDetailVC: UIViewController {
    
    var IdReceived = 0
    var phoneText = ""
    var emailTxt = ""
    fileprivate let application = UIApplication.shared

    @IBOutlet weak var masjidNameLabel: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
        networkHit()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item2"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func phoneBtnPressed(_ sender: UIButton) {
        if phoneText != "" {
            callOnNumber()
        }
    }
    
    @IBAction func emailBtnPressed(_ sender: UIButton) {
        if emailTxt != "" {
            sendMail()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension AnnouncementDetailVC: ThreeDotProtocol {
    
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
    
    func refreshBtnPressed() {
        print("Do nothing")
    }
    
    func shareBtnPressed() {
        sharePrayersData()
    }
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension AnnouncementDetailVC: MFMailComposeViewControllerDelegate {
    
    func sharePrayersData(){
        
        var text2Share = "****** allMasajid - Announcement ******\n\n"
        text2Share = text2Share + "- Title: \(titleLable.text!)\n - Mosque: \(masjidNameLabel.text!)\n - Description: \(descriptionLabel.text!) \n\n Contact Details:\n- Phone: \(phoneText)\n- Email: \(emailTxt)"
        text2Share = text2Share + "\n\nLooking for an authentic and portable solution to bring public attention to your organization’s announcement? So this app is specially designed for you. allMasajid will effectively deliver your message to the respective community./nFor Android: https://bit.ly/2zCeFwM/nFor IOS: https://apple.co/2zHQXzo/nWhat are you waiting for? Download our app now."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            activity.popoverPresentationController?.sourceView = self.masjidNameLabel
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
    }
    
    func sendMail(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(emailTxt)"])
            mail.setSubject("\(titleLable.text!)")
            mail.setMessageBody("<p><br><br><br> Sending email from allMasajid</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            openGmail()
        }
    }
    
    func openGmail(){
        let address = emailTxt
        let subject = "\(titleLable.text!)"
        let buildInfo = "Sending email from allMasajid"
        let googleUrlString = "googlegmail:///co?to=\(address.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&subject=\(subject.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&body=\(buildInfo.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"

        if let googleUrl = URL(string: googleUrlString) {
            UIApplication.shared.open(googleUrl, options: [:]) {
                success in
                if !success {
                    HUD.flash(.labeledError(title: "Unable to send email", subtitle: "Make sure you have mail app setup"), delay: 0.8)
                }
            }
        }
        else {
            HUD.flash(.labeledError(title: "Unable to send email", subtitle: "Make sure you have mail app setup"), delay: 0.8)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func callOnNumber(){
        if let phoneURL = URL(string: "tel://\(phoneText)"){
            if application.canOpenURL(phoneURL){
                application.open(phoneURL, options: [:], completionHandler: nil)
            }else{
                HUD.flash(.labeledError(title: "Faliure", subtitle: "Unable to call at this moment"), delay: 0.8)
            }
        }
    }
}

extension AnnouncementDetailVC: TryAgainProtocol {
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        
//        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
//            APIRequestUtil.GetAnnouncementById(Id: "\(IdReceived)", headers: [:], completion: APIRequestCompleted)
//        }else{
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.GetAnnouncementById(Id: "\(IdReceived)", headers: httpHeaders, completion: APIRequestCompleted)
//        }
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let email = json["email"].stringValue
            let image = json["image"].stringValue
            let description = json["description"].stringValue
            let contact = json["contact"].stringValue
            let title = json["title"].stringValue
            
            let masajid = json["masajid"]
            let name = masajid["name"].stringValue
            
            masjidNameLabel.text = "\(name)"
            titleLable.text = "\(title)"
            phoneText = "\(contact)"
            emailTxt = "\(email)"
            descriptionLabel.text = "\(description)"
        
            phoneBtn.setTitle(phoneText, for: .normal)
            emailBtn.setTitle(emailTxt, for: .normal)
            
            if image != ""{
                GetImage.getImage(url: URL(string: image)!, image: myImageView)
            }
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
