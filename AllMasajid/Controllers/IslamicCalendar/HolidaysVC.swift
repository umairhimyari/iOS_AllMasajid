//
//  HolidaysVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 16/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import SafariServices
import PKHUD
import SwiftyJSON
import EventKit

class HolidaysVC: UIViewController {

    var eventAccess = false
    let eventStore : EKEventStore = EKEventStore()
    var holidaysArray = [IslamicCalendarModel]()
    
    let dateFormatter = DateFormatter()
    
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    
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
        vc.screen = "item5"
        self.parent?.present(vc, animated: false, completion: nil)
    }
}


extension HolidaysVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "ic"
        vc.titleStr = "Islamic Calendar"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        setupInitials()
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
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

extension HolidaysVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return holidaysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "ICHolidaysTVC", for: indexPath) as! ICHolidaysTVC
        
        let item = holidaysArray[indexPath.row]
        
        let startDateStr = "\(item.englishyear)-\(item.englishMonth)-\(item.englishDay)"
        print(startDateStr)
        let startDate = dateFormatter.date(from: startDateStr)!
        let endDate = Date(timeInterval: 86400, since: startDate)
        
        var holidayText = ""
        for i in 0..<item.holidays.count{
            holidayText = holidayText == "" ? item.holidays[i] : holidayText + ", \(item.holidays[i])"
        }
        
        var eventStatus = false
        if eventAccess {
            eventStatus = checkEventStatus(startDate: startDate, endDate: endDate, eventTitle: holidayText)
        }
        
        if indexPath.row == 0 {
            cell.configureCell(item: item, isFirst: true, titleTxt: holidayText, eventStatus: eventStatus)
        }else{
            cell.configureCell(item: item, isFirst: false, titleTxt: holidayText, eventStatus: eventStatus)
        }
        
        cell.bellBTN.addTarget(self, action: #selector(bellBtnPressed), for: .touchUpInside)
        cell.bellBTN.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    @objc func bellBtnPressed(sender: UIButton){
        
        let index = sender.tag
        let item = holidaysArray[index]
        
        let startDateStr = "\(item.englishyear)-\(item.englishMonth)-\(item.englishDay)"
        
        let startDate = dateFormatter.date(from: startDateStr) ?? Date()
        let endDate = Date(timeInterval: 86400, since: startDate)//Date(timeIntervalSinceNow: startDate)
        
        var holidayText = ""
        for i in 0..<item.holidays.count{
            holidayText = holidayText == "" ? item.holidays[i] : holidayText + ", \(item.holidays[i])"
        }
        
        if eventAccess {
            makeEvent(startDate: startDate, endDate: endDate, eventTitle: holidayText)
        }else{
            HUD.flash(.label("Please allow permission to use calendars in settings"), delay: 1)
        }
        
        myTableView.reloadData()
    }
}


extension HolidaysVC {
    
    func setupInitials(){
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        eventStore.requestAccess(to: .event) { [self] (granted, error) in
            if (error == nil) {
                if granted != true {
                    HUD.flash(.label("Please allow permission to use calendars in settings"), delay: 1)
                    return
                }
                eventAccess = true
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "ICHolidaysTVC", bundle: nil), forCellReuseIdentifier: "ICHolidaysTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}


extension HolidaysVC: TryAgainProtocol {
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false
        
        var dateAdjustment = ""
        if UserDefaults.standard.bool(forKey: "dateAdjustmentStatus") == true {
            dateAdjustment = UserDefaults.standard.object(forKey: "dateAdjustment") as! String
        }else{
            dateAdjustment = "0"
        }
        
        APIRequestUtil.GetHolidaysList(dateAdjustment: dateAdjustment, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            
            let json = JSON(response)
            print(json)
                        
            holidaysArray.removeAll()
            
            for i in 0..<json.count {
                let hijri = json[i]["hijri"]
                let islamicDay = Int(hijri["day"].stringValue) ?? 0
                
                let islamicMonth = hijri["month"]
                let islamicMonthNumber = islamicMonth["number"].intValue
                let islamicMonthStr = islamicMonth["en"].stringValue
                
                let islamicYear = Int(hijri["year"].stringValue) ?? 0
                
                let gregorian = json[i]["gregorian"]
                let englishDay = Int(gregorian["day"].stringValue) ?? 0
                let englishMonth = gregorian["month"]
                let englishMonthNumber = englishMonth["number"].intValue
                let englishMonthStr = englishMonth["en"].stringValue
                let englishYear = Int(gregorian["year"].stringValue) ?? 0
                
                let diffInDays = json[i]["diffInDays"].intValue
                
                let holidays = hijri["holidays"].arrayValue
                var holidayArray = [String]()
                
                for i in 0..<holidays.count{
                    holidayArray.append(holidays[i].stringValue)
                }
                
                holidaysArray.append(IslamicCalendarModel(englishDay: englishDay, englishMonth: englishMonthNumber, englishyear: englishYear, englishMonthStr: englishMonthStr, islamicDay: islamicDay, islamicMonth: islamicMonthNumber, islamicMonthStr: islamicMonthStr, islamicYear: islamicYear, holidays: holidayArray, diffInDays: diffInDays))
            }
            
            self.myTableView.reloadData()
            HUD.hide()
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}
///*
extension HolidaysVC {
    
    func checkEventStatus(startDate: Date, endDate: Date, eventTitle: String) -> Bool {

        var eventAlreadyExists = false
        
        let event = EKEvent(eventStore: eventStore)
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        eventAlreadyExists = existingEvents.contains(where: {event in eventTitle == event.title && event.startDate == startDate && event.endDate == endDate})
        
        return eventAlreadyExists
    }
    
    func makeEvent(startDate: Date, endDate: Date, eventTitle: String){
        if checkEventStatus(startDate: startDate, endDate: endDate, eventTitle: eventTitle) == true {
            HUD.flash(.label("Event already exists"), delay: 0.8)
        }else{
            do {
                let event = EKEvent(eventStore: eventStore)
                event.title = eventTitle
                event.startDate = startDate
                event.endDate = endDate
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                try self.eventStore.save(event, span: .thisEvent)
                
                HUD.flash(.labeledSuccess(title: "Success", subtitle: "Event Saved on Calendar"), delay: 0.8)
                
            } catch {
                HUD.flash(.labeledError(title: "Faliure", subtitle: "Unable to save event at this moment"), delay: 0.8)
                return
            }
        }
    }
    
    
    /*
     
     
     func checkEvent(){
         let startDate = Date(timeIntervalSinceNow: 86400)
         let endDate = Date(timeIntervalSinceNow: 172800)
         var eventAlreadyExists = false
         let event = EKEvent(eventStore: eventStore)
         event.title = "My Event"
         event.startDate = startDate
         event.endDate = endDate
         event.calendar = eventStore.defaultCalendarForNewEvents

         let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
 //        let existingEvents = eventStore.events(matching: predicate)

         eventStore.fetchReminders(matching: predicate) { (reminder) in
             eventAlreadyExists = true
         }
         
 //        let eventAlreadyExists = existingEvents.contains(where: {event in self.dataEvent?.titleString == event.title && event.startDate == startDate && (event.endDate != nil) = endDate})

         // Matching event found, don't add it again, just display alert
         if eventAlreadyExists {
             HUD.flash(.label("Event already exists"), delay: 0.8)
         } else {
             // Event doesn't exist yet, add it to calendar
             do {
                 try eventStore.save(event, span: .thisEvent)
 //                savedEventId = ""
                 print("Event Added")
                 let alert = UIAlertController(title: "Event Successfully Added", message: "Event Added to Calendar", preferredStyle: UIAlertController.Style.alert)
                 alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                 self.present(alert, animated: true, completion: nil)
             } catch {
                 print("Error occurred")
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
*/
}
