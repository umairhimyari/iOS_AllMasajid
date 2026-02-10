//
//  IslamicCalendarVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 08/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import FSCalendar

class IslamicCalendarVC: UIViewController {

    var todaysDate = 0
    var currentMonth = 0
    var activeDisplayMonth = 0
    
    var selectedDate: Date?
    
    var calendarArray = [IslamicCalendarModel]()
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var englishDateLBL: UILabel!
    @IBOutlet weak var islamicDateLBL: UILabel!
    @IBOutlet weak var todayIslamicDateLBL: UILabel!
    @IBOutlet weak var eventsLBL: UILabel!
    @IBOutlet weak var prayerTimesBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
        /*
        if UserDefaults.standard.bool(forKey: "introIC") != true {
            UserDefaults.standard.set(true, forKey: "introIC")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Islamic Calendar"
            vc.screenName = "islamic_calendar"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
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
    
    @IBAction func getPrayerTimesPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadICPrayerTimesScreen()
        
        if let date = selectedDate {
            vc.selectedDateReceived = date
            vc.islamicDateReceived = islamicDateLBL.text!
        }else{
            vc.selectedDateReceived = Date()
            vc.islamicDateReceived = todayIslamicDateLBL.text!
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func checkHolidaysPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadHolidaysScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension IslamicCalendarVC: ThreeDotProtocol {
    
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
        print("Do Nothing")
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

extension IslamicCalendarVC: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        selectedDate = date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let currDate = Int(formatter.string(from: date)) ?? 0
        
        setupIslamicDateDisplay(dateInt: currDate)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        islamicDateLBL.text = ""
        eventsLBL.text = ""
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MM"
        activeDisplayMonth = Int(formatter2.string(from: calendar.currentPage)) ?? 0
        
        getDateSetup(date: calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let currDate = Int(formatter.string(from: date)) ?? 0
        
        var text = ""
        
        for i in 0..<calendarArray.count {
            if calendarArray[i].englishDay == currDate && calendarArray[i].englishMonth == activeDisplayMonth{ //ADDED NEW FROM &&
                text = "\(calendarArray[i].islamicDay)"
            }
        }
        
        return text
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let currDate = Int(formatter.string(from: date)) ?? 0

        for i in 0..<calendarArray.count {
            if calendarArray[i].englishDay == currDate && calendarArray[i].holidays.count > 0 && calendarArray[i].englishMonth == activeDisplayMonth{ //ADDED NEW FROM 2nd &&
                return calendarArray[i].holidays.count
            }
        }
        
        return 0
    }
}

extension IslamicCalendarVC {
    
    func setupTheme(){
        self.calendar.appearance.weekdayTextColor = .white
        self.calendar.headerHeight = 0
        self.calendar.placeholderType = .none
        self.calendar.appearance.titleDefaultColor = .white
        self.calendar.appearance.subtitleDefaultColor = #colorLiteral(red: 0.529861927, green: 0.8257446885, blue: 0.9637567401, alpha: 1)
        self.calendar.appearance.eventDefaultColor = .systemGreen
    }
    
    func setupToday(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        todaysDate = Int(formatter.string(from: Date())) ?? 0
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MM"
        currentMonth = Int(formatter2.string(from:Date())) ?? 0
        activeDisplayMonth = currentMonth
    }
    
    func getDateSetup(date: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy"
        
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "MMMM"
        
        englishDateLBL.text = "\(formatter3.string(from: date)) \(formatter2.string(from: date))"
        
        let todayMonth = Int(formatter.string(from:date)) ?? 0
        let todaysYear = Int(formatter2.string(from:date)) ?? 0
        
        networkHit(month: todayMonth, year: todaysYear)
    }
    
    func setupIslamicDateDisplay(dateInt: Int){
        var todayText = ""
        var holidayText = ""
        
        for i in 0..<calendarArray.count {
            if calendarArray[i].englishDay == dateInt {
                for j in 0..<calendarArray[i].holidays.count {
                    holidayText = holidayText == "" ? calendarArray[i].holidays[j] : "\(holidayText), \(calendarArray[i].holidays[j])"
                }
                todayText = "\(calendarArray[i].islamicDay) \(calendarArray[i].islamicMonthStr), \(calendarArray[i].islamicYear)"
                
            }
        }
        eventsLBL.text = holidayText
        islamicDateLBL.text = todayText
        
    }
    
    func setupInitials(){
        calendar.delegate = self
        calendar.dataSource = self
        setupTheme()
        
        self.calendar.appearance.caseOptions = [.weekdayUsesUpperCase]
        
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        
        setupToday()
        getDateSetup(date: Date())
    }
}

extension IslamicCalendarVC: TryAgainProtocol {
    
    func tryAgain() {
        print("Do Something")
        setupInitials()
    }
    
    func networkHit(month: Int, year: Int){
        HUD.show(.progress)
        print("Month: \(month), Year: \(year)")
        self.view.isUserInteractionEnabled = false
        
        var dateAdjustment = ""
        if UserDefaults.standard.bool(forKey: "dateAdjustmentStatus") == true {
            dateAdjustment = UserDefaults.standard.object(forKey: "dateAdjustment") as! String
        }else{
            dateAdjustment = "0"
        }
        
        APIRequestUtil.GetIslamicCalendar(month: month, year: year, dateAdjustment: dateAdjustment, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            
            let json = JSON(response)
            print(json)
            
            let data = json["data"]
            
            calendarArray.removeAll()
            
            for i in 0..<data.count {
                let hijri = data[i]["hijri"]
                let islamicDay = Int(hijri["day"].stringValue) ?? 0
                
                let islamicMonth = hijri["month"]
                let islamicMonthNumber = islamicMonth["number"].intValue
                let islamicMonthStr = islamicMonth["en"].stringValue
                
                let islamicYear = Int(hijri["year"].stringValue) ?? 0
                
                let gregorian = data[i]["gregorian"]
                let englishDay = Int(gregorian["day"].stringValue) ?? 0
                let englishMonth = gregorian["month"]
                let englishMonthNumber = englishMonth["number"].intValue
                let englishMonthStr = englishMonth["en"].stringValue
                let englishYear = Int(englishMonth["year"].stringValue) ?? 0
                
                let holidays = hijri["holidays"].arrayValue
                var holidayArray = [String]()
                
                for i in 0..<holidays.count{
                    holidayArray.append(holidays[i].stringValue)
                }
                
                calendarArray.append(IslamicCalendarModel(englishDay: englishDay, englishMonth: englishMonthNumber, englishyear: englishYear, englishMonthStr: englishMonthStr, islamicDay: islamicDay, islamicMonth: islamicMonthNumber, islamicMonthStr: islamicMonthStr, islamicYear: islamicYear, holidays: holidayArray))
            }
                        
            for i in 0..<calendarArray.count {
                if calendarArray[i].englishDay == todaysDate && calendarArray[i].englishMonth == currentMonth {
                    todayIslamicDateLBL.text  = "\(calendarArray[i].islamicDay) \(calendarArray[i].islamicMonthStr), \(calendarArray[i].islamicYear)"
                }
            }
            
            self.calendar.reloadData()
            HUD.hide()
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


/*
let _calendar = Calendar.current
var dateComponents = DateComponents()
dateComponents.month = 1 // For next button
dateComponents.month = -1 // For prev button
self.currentPage = _calendar.date(byAdding: dateComponents, to: self.currentPage!)

self.calendar.setCurrentPage(self.currentPage!, animated: true)// calender is object of FSCalendar
*/


//        selectedDate = nil
//
//        let abc = Calendar.current
//        var dateComponents = DateComponents()
//        dateComponents.month = 0
//        let currentPage = abc.date(byAdding: dateComponents, to: calendar.currentPage)
//        self.calendar.setCurrentPage(currentPage!, animated: true)
//
//        setupInitials()
