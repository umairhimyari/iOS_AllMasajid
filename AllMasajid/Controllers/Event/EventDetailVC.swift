//
//  EventDetailVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/06/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices
import MessageUI
import EventKit

class EventDetailVC: UIViewController, ThreeDotProtocol{
    
    var myLocation = CLLocation()
    
    var masjidLong = ""
    var masjidLat = ""
    
    var IdReceived = 0
    var email = ""
    var eventTitle = ""
    var message = ""
    var contact = ""
    var time = ""
    var address = ""
    var eventDescription = ""
    var date = ""
    var link = ""
    var masjidName = ""
    
    var eventSaved = 0
    
    fileprivate let application = UIApplication.shared
    
    let eventStore : EKEventStore = EKEventStore()

    @IBOutlet weak var masjidNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var webBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var dateTimeBtn: UIButton!
    @IBOutlet weak var addressBtn: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var msgFromHostLabel: UILabel!
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(IdReceived)
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
    
    @IBAction func webBtnPressed(_ sender: UIButton) {
        if link != "" {
            if !link.contains("www"){
                link = "https://www." + link
            }else if !link.contains("http"){
                link = "https://" + link
            }
            print(link)
            guard let url = URL(string: link) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func phoneBtnPressed(_ sender: UIButton) {
        if contact != "" {
            callOnNumber()
        }
    }
    
    @IBAction func emailBtnPressed(_ sender: UIButton) {
        if email != "" {
            sendMail()
        }
    }
    
    @IBAction func dateTimePressed(_ sender: UIButton) {
        makeEvent()
    }
    
    @IBAction func addressBtnPressed(_ sender: UIButton) {
        getDirectionsToMasjid(lat: masjidLat, long: masjidLong)
    }
    
    func tryAgain() {
        networkHit()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension EventDetailVC {
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
    
    func refreshBtnPressed() {
        print("Do Nothing")
    }
    
    func shareBtnPressed() {
        sharePrayersData()
    }
    
    func addBtnPressed() {
        print("Do Nothing")
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
    
    func sharePrayersData(){
        
        var text2Share = "****** allMasajid - Event ******\n\n"
        text2Share = text2Share + "- Title: \(eventTitle)\n- Mosque: \(masjidName)\n Address: \(address)\n- Description: \(eventDescription)\n- Link: \(link) \n- Date & Time: \(date) at \(time) \n\nContact Details:\n- Phone: \(contact)\n- Email: \(email)"
        text2Share = text2Share + "\n\nYou are organizing an event but fret to reach the community?  Don’t hunt for futile solutions.\nallMasajid will help you out with your event promotions. Make your event exemplary with allMasajid./nFor Android: https://bit.ly/2zCeFwM/nFor IOS: https://apple.co/2zHQXzo/nDownload our app to make your event outstanding with AllMasajid."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            activity.popoverPresentationController?.sourceView = self.masjidNameLabel
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
    }
}

extension EventDetailVC: MFMailComposeViewControllerDelegate {
    
    func sendMail(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(email)"])
            mail.setSubject("\(eventTitle)")
            mail.setMessageBody("<p><br><br><br> Sending email from allMasajid</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            openGmail()
        }
    }
    
    func openGmail(){
        
        let address = email
        let subject = eventTitle
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
        if let phoneURL = URL(string: "tel://\(contact)"){
            if application.canOpenURL(phoneURL){
                application.open(phoneURL, options: [:], completionHandler: nil)
            }else{
                HUD.flash(.labeledError(title: "Faliure", subtitle: "Unable to call at this moment"), delay: 0.8)
            }
        }
    }
    
    func makeEvent(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let eventDate = dateFormatter.date(from: date)
        
        eventStore.requestAccess(to: .event) { (granted, error) in
          
            if (granted) && (error == nil) {
                if granted != true {
                    self.eventStatus(flag: 2)
                    return
                }

                let event:EKEvent = EKEvent(eventStore: self.eventStore)

                event.title = "\(self.eventTitle)"
                event.startDate = eventDate
                event.endDate = eventDate
                event.notes = "\(self.eventDescription)"
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                } catch {
                    self.eventStatus(flag: 0)
                    return
                }
                self.eventStatus(flag: 1)
            }else{
                self.eventStatus(flag: 0)
            }
        }
    }
    
    func eventStatus(flag: Int){
        DispatchQueue.main.async {
            if flag == 0 {
                HUD.flash(.labeledError(title: "Faliure", subtitle: "Unable to save event at this moment"), delay: 0.8)
            }else if flag == 2 {
                HUD.flash(.label("Please allow permission to use calendars in settings"), delay: 0.8)
            }else if flag == 1{
                HUD.flash(.labeledSuccess(title: "Success", subtitle: "Event Saved on Calendar"), delay: 0.8)
            }
        }
    }
    
    func getDirectionsToMasjid(lat: String, long: String){
        
        if (UIApplication.shared.canOpenURL(URL(string:"https://www.google.com/maps/")!)) {
            
            UIApplication.shared.open(URL(string:
                "https://www.google.com/maps?saddr=\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)&daddr=\(lat),\(long)")!, options: [:], completionHandler: nil)
        } else {
            let directionsURL = "http://maps.apple.com/?daddr=\(lat),\(long)&t=m&z=10"
            guard let url = URL(string: directionsURL) else {
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension EventDetailVC: TryAgainProtocol{
    
    func networkHit(){
        HUD.show(.progress)
        
//        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
//            APIRequestUtil.GetEventById(Id: "\(IdReceived)", headers: [:], completion: APIRequestCompleted)
//        }else{
//            let headers = ["Authorization": "Bearer \(myToken)"]
            APIRequestUtil.GetEventById(Id: "\(IdReceived)", headers: httpHeaders, completion: APIRequestCompleted)
//        }
        
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "error"{
                let error = json["error"].stringValue
                HUD.flash(.labeledError(title: "Error", subtitle: error))
            }else{
                email = json["email"].stringValue
                eventTitle = json["title"].stringValue
                message = json["message"].stringValue
                contact = json["contact"].stringValue
                time = json["time"].stringValue
                address = json["address"].stringValue
                eventDescription = json["description"].stringValue
                date = json["date"].stringValue
                link = json["link"].stringValue
                let image = json["image"].stringValue
                
                let masajid = json["masajid"]
                masjidName = masajid["name"].stringValue
                masjidLong = "\(masajid["long"].doubleValue)"
                masjidLat = "\(masajid["lat"].doubleValue)"
                
                masjidNameLabel.text = masjidName
                titleLabel.text = eventTitle
                
                webBtn.setTitle(link, for: .normal)
                phoneBtn.setTitle(contact, for: .normal)
                emailBtn.setTitle(email, for: .normal)
                dateTimeBtn.setTitle("\(date) at \(time)", for: .normal)
                addressBtn.setTitle(address, for: .normal)
                descriptionLabel.text = eventDescription == "" ? "N/A": eventDescription
                msgFromHostLabel.text = message == "" ? "N/A": message
                
                if image != ""{
                    GetImage.getImage(url: URL(string: image)!, image: myImageView)
                }else{
                    myImageView.image = #imageLiteral(resourceName: "logo")
                }
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
