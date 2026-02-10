//
//  EventsViewController.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 21/05/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import MessageUI
import SwiftyJSON
import CoreLocation

class EventsViewController: UIViewController {
        
    var masajidData : [MasjidItem] = []
    var eventsArr = [EventsModel]()
    var myLocation = CLLocation()
    
    var checkScreen = ""
    var selectedMasjid: MasjidItem?
    var masjidReceived: MyMasajidModel?
    
    @IBOutlet var footerView: UIView!
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var masjidNameLabel: UILabel!
    @IBOutlet weak var noRecordLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotBtnPressed(_ sender: Any) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item1"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func emailBtnPressed(_ sender: UIButton) {
        sendMail()
    }
}

extension EventsViewController: ThreeDotProtocol {
    func addBtnPressed() {
        let vc = UIStoryboard().LoadAddEventScreen()
        vc.selectedMasjid = selectedMasjid
        vc.masjidReceived = masjidReceived
        vc.checkScreen = checkScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
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
        eventsArr.removeAll()
        hitAPI()
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension EventsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "EventTVC", for: indexPath) as! EventTVC
        cell.eventTitle?.text = eventsArr[indexPath.row].title
        cell.eventDescriptionLabel?.text = eventsArr[indexPath.row].date
        cell.dateLBL.text = "\(eventsArr[indexPath.row].time), \(eventsArr[indexPath.row].date)"
        
        if eventsArr[indexPath.row].status == 1{
            cell.verifyImageView.image = #imageLiteral(resourceName: "verifiedIcon")
        }else if eventsArr[indexPath.row].status == 0{
            cell.verifyImageView.image = #imageLiteral(resourceName: "unverifiedIcon")
        }
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
            cell.favoriteBTN.isHidden = true
        }
        
        let image = eventsArr[indexPath.row].image
        if image != ""{
            GetImage.getImage(url: URL(string: image)!, image: cell.eventImageView)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadEventDetailsScreen()
        vc.IdReceived = eventsArr[indexPath.row].id
        vc.myLocation = myLocation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

extension EventsViewController: MFMailComposeViewControllerDelegate, TryAgainProtocol {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)

        myTableView.register(UINib(nibName: "EventTVC", bundle: nil), forCellReuseIdentifier: "EventTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        hitAPI()
    }
    
    func hitAPI(){
        if checkScreen == "nearby"{
            masjidNameLabel.text = selectedMasjid?.name
            networkHitByMasjidId(masjidId: selectedMasjid?.id ?? "")
        }else if checkScreen == "myMasajid"{
            masjidNameLabel.text = masjidReceived?.name
            networkHitByMasjidId(masjidId: masjidReceived?.google_masajid_id ?? "")
        }else{
            networkHit()
        }
    }
    
    func tryAgain() {
        refreshBtnPressed()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func sendMail(){
        let myTodayDate = getTodayDate()
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(emailEvents)"])
            mail.setSubject("Add Event Request")
            mail.setMessageBody("<p><br><br><br> Date & Time = \(myTodayDate)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            openGmail()
        }
    }
    
    func openGmail(){
        
        let myTodayDate = getTodayDate()
        let address = emailEvents
        let subject = "Add Event Request"
        let buildInfo = "Date & Time = \(myTodayDate)"
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
    
    func getTodayDate() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h:mm a"

        let now = Date()
        return "\(formatter2.string(from:now)), \(formatter.string(from:now))"
    }
}


extension EventsViewController{
    
    func networkHit(){
        HUD.show(.progress)
        APIRequestUtil.GetAllEvents(completion: APIRequestCompleted)
    }
    
    func networkHitByMasjidId(masjidId: String){
        HUD.show(.progress)
        APIRequestUtil.GetEventsByMasjidId(masjidId: masjidId, completion: APIRequestByMasjidCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            eventsArr.removeAll()
                        
            for index in 0..<json.count{
                let model = EventsModel(fromJson: json[index])
                eventsArr.append(model)
            }
            myTableView.reloadData()
            
            if eventsArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
                noRecordLBL.isHidden = false
            }else{
                noRecordLBL.isHidden = true
            }
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
    
    
    fileprivate func APIRequestByMasjidCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            eventsArr.removeAll()
                        
            let event = json["event"].arrayValue
            for index in 0..<event.count{
                let model = EventsModel(fromJson: event[index])
                eventsArr.append(model)
            }
            myTableView.reloadData()
            
            if eventsArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
                noRecordLBL.isHidden = false
            }else{
                noRecordLBL.isHidden = true
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
