//
//  APIRequestUtil.swift
//  Global Paint
//
//  Created by Apple on 01/09/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


typealias RequestCompletion = (_ response: Any?, _ error: Error?) -> Void

class APIRequestUtil {
    
    //PRODUCTION
//    public static let BASE_URL = "http://app.allmasajid.net/api/"
    public static let BASE_URL = "http://api.allmasajid.net/api/"
    
    //TESTING URLs
//    public static let BASE_URL = "https://allm-upgraded.allmasajid.co/api/"
//    public static let BASE_URL = "https://api.allmasajid.co/api/"
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------- Authentication
    // ------------------------------------------------------------------------------------------------
    
    public static func Login(headers: HTTPHeaders, parameters: [String:String], completion: @escaping RequestCompletion)
    {
        formData(myURL: "login", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func Register(headers: HTTPHeaders, parameters: [String:String], completion: @escaping RequestCompletion)
    {
        formData(myURL: "register", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func ForgetPassword(parameters: [String:String], completion: @escaping RequestCompletion)
    {
        formData(myURL: "forgot-password", parameters: parameters, headers: HTTPHeaders(), completion: completion)
    }
    
    public static func Logout(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "logout", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func SocialLogin(headers: HTTPHeaders, parameters: [String:String], completion: @escaping RequestCompletion)
    {
        formData(myURL: "social-login", parameters: parameters, headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------- White Fasting Days
    // ------------------------------------------------------------------------------------------------
    
    public static func GetWhiteFastingDays(dateAdjustment: Int, dateMonth: String, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "wfdays?setting=\(dateAdjustment)&dm=\(dateMonth)", headers: HTTPHeaders(), completion: completion)
    }

    public static func GetWhiteFastingDays(completion: @escaping RequestCompletion)
    {
        GETRequest(url: "fasting-days", headers: HTTPHeaders(), completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------- FAQs + How 2 Use App
    // ------------------------------------------------------------------------------------------------
    
    public static func GetFAQs(screenName: String, completion: @escaping RequestCompletion)
    {
        // Map screen names to API group values
        // API groups: settings, dua, announcement, events, iqamah, my_masajid,
        // nearby_masajid, qibla, islamic_calendar, prayer_timing, dua_appeals, contribute, ramadan_special
        let groupMapping: [String: String] = [
            "ic": "islamic_calendar",
            "ramadan": "ramadan_special"
        ]
        let group = groupMapping[screenName] ?? screenName
        GETRequest(url: "faq?group=\(group)", headers: HTTPHeaders(), completion: completion)
    }
    
    public static func GetHow2UseCategories(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "modules", headers: headers, completion: completion)
    }
    
    public static func GetHow2UseDetail(screenName: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "intro-screen/\(screenName)", headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------- Feedback
    // ------------------------------------------------------------------------------------------------
    
    public static func SendFeedback(parameters: [String:String], completion: @escaping RequestCompletion)
    {
        formData(myURL: "feedback", parameters: parameters, headers: HTTPHeaders(), completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------- Masajids
    // ------------------------------------------------------------------------------------------------
    
    public static func AddMasjid(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "add-masajid", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetMasajid(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "masajid", headers: headers, completion: completion)
    }
    
    public static func RemoveMasjid(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "masajid/\(id)", headers: headers, completion: completion)
    }
    
    public static func NearByMasajid(latitude: String, longitude: String, radius: String, completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=mosque&key=\(Secrets.googleMapsAPIKey)", headers: HTTPHeaders(), completion: completion)
    }
    
    public static func GetNearByMasajid(latitude: String, longitude: String, radius: String, units: String, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "near-by-masajids?lat=\(latitude)&long=\(longitude)&radius=\(radius)&unit=\(units)", headers: HTTPHeaders(), completion: completion)
    }
        
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------- Announcements
    // ------------------------------------------------------------------------------------------------
    
    public static func AddMasjidAnnouncement(parameters: [String:String], headers: HTTPHeaders, imageData: Data, fileName: String, completion: @escaping RequestCompletion)
    {
        SendMultipart(myURL: "announcement", parameters: parameters, imageData: imageData, fileName: fileName, headers: headers, completion: completion)
    }
    
    public static func AddMasjidAnnouncementWithoutImage(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "announcement", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetAllAnnouncements(completion: @escaping RequestCompletion)
    {
        GETRequest(url: "announcement", headers: HTTPHeaders(), completion: completion)
    }

    public static func GetAnnouncementById(Id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "announcement/\(Id)", headers: headers, completion: completion)
    }

    public static func GetAnnouncementsByMasjidId(masjidId: String, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "google-masajid/\(masjidId)?with=announcement", headers: HTTPHeaders(), completion: completion)
    }
    
    public static func GetNearByAnnouncements(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "near-by-announcements", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetFavoriteAnnouncements(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-fav-announcements", headers: headers, completion: completion)
    }
    
    public static func MakeFavoriteAnnouncement(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "announcements/add-to-fav/\(id)", headers: headers, completion: completion)
    }
    
    public static func RemoveFavoriteAnnouncement(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "announcements/remove-to-fav/\(id)", headers: headers, completion: completion)
    }
    
    public static func GetPersonalAnnouncements(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-announcements", headers: headers, completion: completion)
    }
    
    public static func RescheduleAnnouncement(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
//        PutFormData(myURL: "user-announcements/reschedule/\(id)", parameters: [:], headers: headers, completion: completion)
    }
    
    public static func RemovePersonalAnnouncement(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "user-announcements/\(id)", headers: headers, completion: completion)
    }
    
    public static func AddNonMasjidAnnouncement(parameters: [String:String], headers: HTTPHeaders, imageData: Data, fileName: String, completion: @escaping RequestCompletion)
    {
        SendMultipart(myURL: "non-announcements", parameters: parameters , imageData: imageData, fileName: fileName, headers: headers, completion: completion)
    }
    
    public static func AddNonMasjidAnnouncementWithoutImage(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "non-announcements", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetNonMasajidAnnouncements(lat: String, long: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "non-announcements?latitude=\(lat)&longitude=\(long)", headers: headers, completion: completion)
    }
    
    public static func GetNonMasajidUserAnnouncements(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-non-announcements", headers: headers, completion: completion)
    }
    
    public static func RemoveNonMasajidPersonalAnnouncement(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "non-announcements/\(id)", headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------- Events
    // ------------------------------------------------------------------------------------------------
    
    public static func AddMasjidEvent(parameters: [String:String], headers: HTTPHeaders, imageData: Data, fileName: String, completion: @escaping RequestCompletion)
    {
        SendMultipart(myURL: "events", parameters: parameters , imageData: imageData, fileName: fileName, headers: headers, completion: completion)
    }
    
    public static func AddMasjidEventWithoutImage(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "events", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetAllEvents(completion: @escaping RequestCompletion)
    {
        GETRequest(url: "events", headers: HTTPHeaders(), completion: completion)
    }

    public static func GetEventById(Id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "events/\(Id)", headers: headers, completion: completion)
    }

    public static func GetEventsByMasjidId(masjidId: String, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "google-masajid/\(masjidId)?with=event", headers: HTTPHeaders(), completion: completion)
    }
    
    public static func GetNearByEvents(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "near-by-events", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetFavoriteEvents(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-fav-events", headers: headers, completion: completion)
    }
    
    public static func MakeFavoriteEvent(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "events/add-to-fav/\(id)", headers: headers, completion: completion)
    }
    
    public static func RemoveFavoriteEvent(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "events/remove-to-fav/\(id)", headers: headers, completion: completion)
    }
    
    public static func GetPersonalEvents(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-events", headers: headers, completion: completion)
    }
    
    public static func RescheduleEvent(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        PutFormData(myURL: "user-events/reschedule/\(id)", parameters: [:], headers: headers, completion: completion)
    }
    
    public static func RemovePersonalEvent(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "user-events/\(id)", headers: headers, completion: completion)
    }
    
    public static func AddNonMasjidEvent(parameters: [String:String], headers: HTTPHeaders, imageData: Data, fileName: String, completion: @escaping RequestCompletion)
    {
        SendMultipart(myURL: "non-events", parameters: parameters , imageData: imageData, fileName: fileName, headers: headers, completion: completion)
    }
    
    public static func AddNonMasjidEventWithoutImage(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "non-events", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetNonMasajidEvents(lat: String, long: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "non-events?latitude=\(lat)&longitude=\(long)", headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------- Organizations
    // ------------------------------------------------------------------------------------------------
    
    public static func GetNearByOrganizations(latitude: String, longitude: String, radius: String, units: String, pageTokenParams: String, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "near-by-non-masajids?lat=\(latitude)&long=\(longitude)&radius=\(radius)&unit=\(units)\(pageTokenParams)", headers: HTTPHeaders(), completion: completion)
    }

    public static func GetGoogleCityName(myURL: String, completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: myURL, headers: HTTPHeaders(), completion: completion)
    }

    public static func GetCityNameFromLongLat(long: String, lat: String, completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(Secrets.googleMapsAPIKey)", headers: HTTPHeaders(), completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------- Daily Duas
    // ------------------------------------------------------------------------------------------------
    
    public static func GetDuasCategories(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "dua-type/\(id)", headers: headers, completion: completion)
    }
    
    public static func GetDuasFromCategory(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "dua-sub-type/\(id)", headers: headers, completion: completion)
    }
    
    public static func GetSingleDua(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "dua/\(id)", headers: headers, completion: completion)
    }
    
    public static func MakeFavouriteDua(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "make-fav-dua/\(id)", headers: headers, completion: completion)
    }
    
    public static func GetFavouriteDuas(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "fav-dua", headers: headers, completion: completion)
    }
    
    public static func RemoveFavouriteDua(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "remove-fav-dua/\(id)", headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------- Profile
    // ------------------------------------------------------------------------------------------------
    
    public static func GetProfile(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user", headers: headers, completion: completion)
    }
    
    public static func EditProfile(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "user", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func GetSkillList(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "skills", headers: headers, completion: completion)
    }
    
    public static func ChangePassword(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        PutFormData(myURL: "update-password", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func ChangeProfileImage(headers: HTTPHeaders, imageData: Data, fileName: String, completion: @escaping RequestCompletion)
    {
        SendMultipart(myURL: "user/upload-image", parameters: [:] , imageData: imageData, fileName: fileName, headers: headers, completion: completion)
    }
    
    public static func DeleteProfile(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "delete-account", parameters: [:], headers: headers, completion: completion)
    }

    public static func RemoveProfileImage(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "user/remove-image", headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------- Contribute
    // ------------------------------------------------------------------------------------------------
    
    public static func GetInterestsList(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "interest", headers: headers, completion: completion)
    }
    
    public static func ContributeTime(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "contribute-with-time", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func ContributeSkills(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "contribute-with-skills", parameters: parameters, headers: headers, completion: completion)
    }
    
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------- Verification OTP
    // ------------------------------------------------------------------------------------------------
    
    public static func VerifyMobileOTP(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "profile/verify-phone", headers: headers, completion: completion)
    }
    
    public static func VerifyEmailOTP(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "verify?type=email", headers: headers, completion: completion)
    }
    
    public static func VerifyOTP(code: String, type: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        // URL encode the code to handle special characters properly
        let encodedCode = code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? code
        GETRequest(url: "verify-code/\(type)?code=\(encodedCode)", headers: headers, completion: completion)
    }
    
//    public static func VerifyCodeOTP(status: String, contact: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
//    {
//        GETRequest(url: "verify-code-otp?status=\(status)&contact=\(contact)", headers: headers, completion: completion)
//    }
    
    public static func VerifyCodeOTP(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "verify-code-otp", parameters: parameters, headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------- Iqamah
    // ------------------------------------------------------------------------------------------------
    
    public static func GetIqamahNearBy(long: String, lat: String, radius: String, unit: String, prayer: String, currTime: String, maghrib: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "iqamah?lat=\(lat)&long=\(long)&radius=\(radius)&unit=\(unit)&prayer=\(prayer)&current_time=\(currTime)&maghrib_time=\(maghrib)&timezone=\(CurrentTimeZone)", headers: headers, completion: completion)
        
    }
    
    public static func SendIqamahData(id: String, parameters: [String:String], completion: @escaping RequestCompletion)
    {
        SendMultipartParamsOnly(myURL: "iqamah?google_masajid_id=\(id)&timezone=\(CurrentTimeZone)", parameters: parameters, headers: HTTPHeaders(), completion: completion)
    }
    
    public static func GetDisplayIqamah(id: String, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "single-iqamah?google_masajid_id=\(id)&timezone=\(CurrentTimeZone)", headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------ DUAA APEALS
    // ------------------------------------------------------------------------------------------------
    
    public static func DisplayAppeals(page: Int, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "req-for-dua?page=\(page)", headers: headers, completion: completion)
    }
    
    public static func SingleAppeal(id: Int, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-dua/\(id)", headers: headers, completion: completion)
    }
    
    public static func SendAppeal(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        POSTRawData(url: "req-for-dua", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func DisplayUserAppeals(page: Int, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "user-dualist?page=\(page)", headers: headers, completion: completion)
    }
    
    public static func EditAppeal(id: Int, parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        PUTRawData(url: "user-dua/\(id)", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func ExtendAppeal(id: Int, parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        PutFormData(myURL: "user-dua-extend/\(id)", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func DeleteAppeal(id: Int, headers: HTTPHeaders, parameters: [String:String], completion: @escaping RequestCompletion)
    {
        DeleteRequest(url: "req-for-dua/\(id)", headers: headers, completion: completion)
    }
    
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------- ISLAMIC CALENDAR
    // ------------------------------------------------------------------------------------------------
    
    public static func GetIslamicCalendar(month: Int, year: Int, dateAdjustment: String, completion: @escaping RequestCompletion)
    {
//        GETRequest(url: "islamic-calendar?month=\(month)&year=\(year)&setting=\(dateAdjustment)", headers: HTTPHeaders(), completion: completion)
        GETRequest(url: "MonthCalender?month=\(month)&year=\(year)&setting=\(dateAdjustment)", headers: HTTPHeaders(), completion: completion)
    }

    public static func GetHolidaysList(dateAdjustment: String, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "islamic-holidays?setting=\(dateAdjustment)", headers: HTTPHeaders(), completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------ FEED A NEED
    // ------------------------------------------------------------------------------------------------
    
    public static func FanSendInformation(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "feed-a-need?donate=1", parameters: parameters, headers: headers, completion: completion)
    }
    
    public static func FanSendMasjidRegister(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "feed-a-need?register=1", parameters: parameters, headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------- SMART NOTIFICATIONS
    // ------------------------------------------------------------------------------------------------
    
    public static func GetNotificationList(page: Int, headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "get-all-notification?page=\(page)", headers: headers, completion: completion)
    }
    
    public static func GetNotificationsSettings(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "get-notification-setting", headers: headers, completion: completion)
    }
    
    public static func SetNotificationsSettings(parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        formData(myURL: "save-notification-setting", parameters: parameters, headers: headers, completion: completion)
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------- MUSLIM DIRECTORY
    // ------------------------------------------------------------------------------------------------
    
    public static func GetMDBusiness(latitude: String, longitude: String, radius: String, keyword: String, type: String, pageToken: String, completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&keyword=\(keyword)type=\(type)&key=\(Secrets.googleMapsDirectoryAPIKey)&pagetoken=\(pageToken)", headers: HTTPHeaders(), completion: completion)
    }
 
    
    // ------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------- Ramadan Special
    // ------------------------------------------------------------------------------------------------
    
    public static func GetRamadanHadith(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "hadiths", headers: headers, completion: completion)
    }
    
    public static func GetRamadanBenefits(headers: HTTPHeaders, completion: @escaping RequestCompletion)
    {
        GETRequest(url: "benefits", headers: headers, completion: completion)
    }
    
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------- Al Quran
    // ------------------------------------------------------------------------------------------------
    
    public static func AlQuranChapters(completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: "https://api.quran.com/api/v4/chapters?language=en", headers: HTTPHeaders(), completion: completion)
    }

    public static func AlQuranJuzs(completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: "https://api.quran.com/api/v4/juzs", headers: HTTPHeaders(), completion: completion)
    }

    public static func AlQuranVerses(params: String, completion: @escaping RequestCompletion)
    {
        GETRequestCompleteURL(url: "https://api.quran.com/api/v4/quran/verses/uthmani\(params)", headers: HTTPHeaders(), completion: completion)
    }
    
    
    
    fileprivate static func formData(myURL: String, parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion){
        let url = BASE_URL + myURL
        print(url)
        print(headers)
        print(parameters)
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: headers).responseJSON { (response) in
          switch response.result {
            
             case .success(let value):
              completion(value, nil)
              break
            
             case .failure(let error):
              print(error.localizedDescription)
              completion(nil, error)
              break
          }
        }
    }
    
    fileprivate static func PutFormData(myURL: String, parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion){
        let url = BASE_URL + myURL
        print(url)
        print(headers)
        print(parameters)
        AF.request(url, method: .put, parameters: parameters, encoding: URLEncoding(), headers: headers).responseJSON { (response) in
          switch response.result {
            
             case .success(let value):
              print(value)
              completion(value, nil)
              break
            
             case .failure(let error):
              print(error.localizedDescription)
              completion(nil, error)
              break
          }
        }
    }
    
    fileprivate static func SendMultipartParamsOnly(myURL: String, parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion){

        let manager = Session.default

        manager.session.configuration.timeoutIntervalForRequest = 50
        manager.session.configuration.timeoutIntervalForResource = 50
        manager.session.configuration.waitsForConnectivity = true
        
        manager.upload(multipartFormData: { (multipartFormData) in

            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            //multipartFormData.append(imageData, withName: "image", fileName: "\(fileName).jpg", mimeType: "image/jpg")

        }, to: BASE_URL + myURL, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                completion(value, nil)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func SendMultipart(myURL: String, parameters: [String:String], imageData: Data, fileName: String, headers: HTTPHeaders, completion: @escaping RequestCompletion){

        print(headers)
        print(parameters)

        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }

            multipartFormData.append(imageData, withName: "image", fileName: "\(fileName).jpg", mimeType: "image/jpg")

        }, to: BASE_URL + myURL, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                completion(value, nil)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func multiPartFormData(myURL: String, parameters: [String:String], headers: HTTPHeaders, completion: @escaping RequestCompletion){

        print(headers)
        print(parameters)

        AF.upload(multipartFormData: { (datav) in

            for (key, value) in parameters {
                datav.append(value.data(using: String.Encoding.utf8)!, withName: key as String)
            }
        }, to: BASE_URL+myURL, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                completion(value, nil)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func POSTRequest(url: String, parameters: Parameters, headers: HTTPHeaders, completion: @escaping RequestCompletion) {

        let manager = Session.default
        manager.session.configuration.timeoutIntervalForRequest = 50
        
        let UrL =  BASE_URL + url
        print(headers)
        print(parameters)
        
        manager.request(UrL ,method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
            print(response)
            switch response.result {
               case .success(let value):
                //success, do anything
                completion(value, nil)
                break
                
               case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)
                break
            }
        }
    }
   
    
    fileprivate static func GETRequest(url: String, headers: HTTPHeaders,
                                       completion: @escaping RequestCompletion) {
        print("----->")
        print(BASE_URL + url)
        print(headers)
        print(headers)
       let manager = Session.default
       manager.session.configuration.timeoutIntervalForRequest = 50
       var request = URLRequest(url: URL(string: BASE_URL + url)!)
       request.allHTTPHeaderFields = headers.dictionary

       request.httpMethod = "GET"
       manager.request(request).responseJSON { (response) in
           print(response)
        switch response.result {
           case .success(let value):
        //success, do anything
            completion(value, nil)
            break
           case .failure(let error):
            print(error.localizedDescription)
            completion(nil, error)
            break
        }
       }
    }

    fileprivate static func GETRequestCompleteURL(url: String, headers: HTTPHeaders,
                                       completion: @escaping RequestCompletion) {

        print(url)
        print(headers)

       let manager = Session.default
       manager.session.configuration.timeoutIntervalForRequest = 50
       var request = URLRequest(url: URL(string: url)!)
       request.allHTTPHeaderFields = headers.dictionary

       request.httpMethod = "GET"
       manager.request(request).responseJSON { (response) in
           print(response)
        switch response.result {
           case .success(let value):
        //success, do anything
            completion(value, nil)
            break
           case .failure(let error):
            print(error.localizedDescription)
            completion(nil, error)
            break
        }
       }
    }
    
    fileprivate static func DeleteRequest(url: String, headers: HTTPHeaders,
                                        completion: @escaping RequestCompletion) {

        print(headers)

        let manager = Session.default
        manager.session.configuration.timeoutIntervalForRequest = 50
        var request = URLRequest(url: URL(string: BASE_URL + url)!)
        request.allHTTPHeaderFields = headers.dictionary
        request.httpMethod = "DELETE"

        manager.request(request).responseJSON { (response) in

            switch response.result {

               case .success(let value):
                completion(value, nil)
                break

               case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error)
                break
            }
        }
    }
    
    
    fileprivate static func POSTRawData(url: String, parameters: Parameters, headers: HTTPHeaders, completion: @escaping RequestCompletion) {

        print(headers)
        print(parameters)

        Session.default.session.configuration.timeoutIntervalForRequest = 50

        guard let url = URL(string: BASE_URL + url) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = headers.dictionary

        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }catch let error{
            print("Error : \(error.localizedDescription)")
        }

        AF.request(request).responseJSON{ (response) in

            switch response.result {

                case .success(let value):
                    completion(value, nil)
                    break

                case .failure(let error):
                print(error.localizedDescription)
                    completion(nil, error)
                    break
            }
        }
    }


    fileprivate static func PUTRawData(url: String, parameters: Parameters, headers: HTTPHeaders, completion: @escaping RequestCompletion) {

        Session.default.session.configuration.timeoutIntervalForRequest = 50

        guard let url = URL(string: BASE_URL + url) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = headers.dictionary

        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }catch let error{
            print("Error : \(error.localizedDescription)")
        }

        AF.request(request).responseJSON{ (response) in

            switch response.result {

                case .success(let value):
                    completion(value, nil)
                    break

                case .failure(let error):
                print(error.localizedDescription)
                    completion(nil, error)
                    break
            }
        }
    }
}
