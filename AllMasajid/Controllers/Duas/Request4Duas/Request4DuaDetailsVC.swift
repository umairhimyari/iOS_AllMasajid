//
//  Request4DuaDetailsVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import MessageUI
import SafariServices
import SwiftyJSON

class Request4DuaDetailsVC: UIViewController {
    
    var idReceived = 0

    var emailTxt = ""
    var contactTxt = ""
    var nameTxt = ""
    var titleTxt = ""
    var appealTxt = ""
    var status = 0
    
    fileprivate let application = UIApplication.shared
    
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var messageLBL: UILabel!
    
    @IBOutlet weak var contactBTN: UIButton!
    @IBOutlet weak var emailBTN: UIButton!
    @IBOutlet weak var contactView: UIView!
    
    @IBOutlet weak var nameLBL: UILabel!
    
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
        vc.screen = "item2"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func contactPressed(_ sender: UIButton) {
        callOnNumber()
    }
    
    @IBAction func emailPressed(_ sender: UIButton) {
        sendMail()
    }
}

extension Request4DuaDetailsVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "dua_appeals"
        vc.titleStr = "Duaa Appeals"
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
        shareData()
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

extension Request4DuaDetailsVC {
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
//        titleLBL.text = titleTxt
//        messageLBL.text = appealTxt
//
//        if status == 1 {
//            contactView.isHidden = true
//            nameLBL.text = "Anoymously Posted"
//        }else{
//            contactView.isHidden = false
//            nameLBL.text = nameTxt
//            let contact = contactTxt == "" ? "N/A" : contactTxt
//            contactBTN.setTitle(contact, for: .normal)
//            emailBTN.setTitle(emailTxt, for: .normal)
//        }
        
        networkHitSingleApeal(id: idReceived)
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func shareData(){
        
        var text2Share = "****** allMasajid - Duua Appeal ******\n\n"
        
        text2Share = text2Share + "- Title: \(titleTxt)\n- Appeal: \(appealTxt)"
        text2Share = text2Share + "\n\nSupplication never goes unheard, It is always accepted if its beneficiary in case for the one. Prophet Muhammad (S.A.W) stated, ‘Duaa of a Muslim for his brother (in Islam) is readily accepted in his absence. ’ Find the freedom of Duaa appeals for the well-being of your loved ones. Through allMasajid, share your favorite supplication or request for Duaa among the community."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activity.popoverPresentationController?.sourceView = self.footerView
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
    }
}

extension Request4DuaDetailsVC: MFMailComposeViewControllerDelegate {
    
    func sendMail(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(emailTxt)"])
            mail.setSubject("\(titleTxt)")
            mail.setMessageBody("<p><br><br><br> Sending email from allMasajid</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            openGmail()
        }
    }
    
    func openGmail(){
        let address = emailTxt
        let subject = titleTxt
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
        if let phoneURL = URL(string: "tel://\(contactTxt)"){
            if application.canOpenURL(phoneURL){
                application.open(phoneURL, options: [:], completionHandler: nil)
            }else{
                HUD.flash(.labeledError(title: "Faliure", subtitle: "Unable to call at this moment"), delay: 0.8)
            }
        }
    }
}

extension Request4DuaDetailsVC{
    
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
            
            status = json["is_secret"].intValue
            emailTxt = json["email"].stringValue
            titleTxt = json["title"].stringValue
            nameTxt = json["user_name"].stringValue
            contactTxt = json["contact_no"].stringValue
            appealTxt = json["appeal"].stringValue
            
            titleLBL.text = titleTxt
            messageLBL.text = appealTxt
            
            if status == 1 {
                contactView.isHidden = true
                nameLBL.text = "Anoymously Posted"
            }else{
                contactView.isHidden = false
                nameLBL.text = nameTxt
                let contact = contactTxt == "" ? "N/A" : contactTxt
                contactBTN.setTitle(contact, for: .normal)
                emailBTN.setTitle(emailTxt, for: .normal)
            }
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
