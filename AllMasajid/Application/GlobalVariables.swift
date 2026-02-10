//
//  GlobalVariables.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

//import Adhan
import Foundation
import Alamofire

let GOOGLE_CONSOLE_CLIENT_ID = Secrets.googleConsoleClientID
var allMWebURL = "https://www.allmasajid.com"
var helpURL = "https://www.allmasajid.com/contact-us/"

var imageBaseURL = "http://web.allmasajid.net/"

var emailIqamah = "iqamah@allmasajid.com"
var emailEvents = "events@allmasajid.com"
var emailAnnouncements = "announcements@allmasajid.com"

var myToken = ""
var myFirebaseToken = ""

var httpHeaders: HTTPHeaders = [:]

var userEmail = ""
var changedSetting = false
var CurrentTimeZone = ""
var settingsVisit = false

let defaults = UserDefaults.standard

let calculationStrings : [String] = ["University of Islamic Sciences", "ISNA", "MAKKAH", "MWL - Muslim World League", "Dubai", "EGYPT", "Singapore"]
let calculationMethods : [CalculationMethod] = [CalculationMethod.karachi, CalculationMethod.northAmerica,   CalculationMethod.ummAlQura, CalculationMethod.muslimWorldLeague, CalculationMethod.dubai, CalculationMethod.egyptian, CalculationMethod.singapore]

let madhabs : [Madhab] = [.hanafi, .shafi]
let dateAdjustments : [String] = ["2","1","0","-1","-2"] //["-2","-1","0","1","2"]
let nearbyRange : [String] = ["5","10","15","20","25","50"]


var TerminatedNotification: NotificationType?
var NotificationID = "0"

enum NotificationType {
    case event
    case announcemet
    case duaAppeal
}

let IslamicMonths = [
    "Muharram",
    "Safar",
    "Rabi al-Awwal",
    "Rabi al-Thani",
    "Jumada al-Awwal",
    "Jumada al-Thani",
    "Rajab",
    "Shaban",
    "Ramadan",
    "Shawwal",
    "Dhu al-Qadah",
    "Dhu al-Hijjah"
]

let EnglishMonths = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
]
