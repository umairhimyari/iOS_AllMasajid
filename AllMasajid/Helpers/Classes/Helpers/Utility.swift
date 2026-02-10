//
//  Utility.swift
//  BaseProject
//
//  Created by Faraz Hussain Siddiqui on 12/19/17.
//  Copyright © 2017 Waqas Ali. All rights reserved.
//

import UIKit
/*

// Class for Utility methods.
public class Utility: NSObject {

    //MARK: - Methods
    
    
    // Execute the close after delay
    public class func delay(seconds delay:Double, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    } 
    
    static func getDate(dateStr : String) -> (String, String, Date) {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputDateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let inputDate = inputDateFormatter.date(from: dateStr)
        {
            
        
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "dd-MM-yyyy"
            outputDateFormatter.timeZone = TimeZone(identifier: "UTC")
            inputDateFormatter.dateFormat = "h:mm a"
            inputDateFormatter.timeZone = TimeZone(identifier: "UTC")
            let timeStamp = inputDateFormatter.string(from: inputDate)
            let otDate = outputDateFormatter.string(from: inputDate)
            let outputDate = outputDateFormatter.date(from: otDate)
            return  (otDate , timeStamp, outputDate!)
        }
        return ("", "", Date())
    }
  
    static func removeAfterSpecificString(str : String, charac : String) -> String {
        if let index = str.range(of: charac)?.lowerBound {
            let substring = str[..<index]
            let modString = String(substring)
            //str = modString  // "ora"
            
            var strModified = str
            strModified = modString
            return strModified
        }
        return ""
    }
    // Make a phone call on the number
    static  func callPhoneNumber(at number:String) {
        let phoneNumber: String = "tel://\(number.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))";
        
        if let phoneURL:URL = URL(string: phoneNumber), UIApplication.shared.canOpenURL(phoneURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(phoneURL);
            }
        }
    }
    
    
    // Calculate the age with given date
    public class func calculateAge (_ dateOfBirth: Date) -> Int {
        let calendar : Calendar = Calendar.current
        let unitFlags : NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day]
        let dateComponentNow : DateComponents = (calendar as NSCalendar).components(unitFlags, from: Date())
        let dateComponentBirth : DateComponents = (calendar as NSCalendar).components(unitFlags, from: dateOfBirth)
        
        if ((dateComponentNow.month! < dateComponentBirth.month!) ||
            ((dateComponentNow.month! == dateComponentBirth.month!) && (dateComponentNow.day! < dateComponentBirth.day!))
            ) {
            return dateComponentNow.year! - dateComponentBirth.year! - 1
        } else {
            return dateComponentNow.year! - dateComponentBirth.year!
        }
    }
    
    ///
    public func getVersionNoString() -> String {
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let str = "Staging"
            return str + " V " + version
        }
        
        return "1.0"
        
    }
    
    static func createNibForTable(cellIdentifier : String, nibName : String , tblView : UITableView){
        let nib = UINib(nibName : nibName , bundle : nil)
        tblView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
    
    public func calculateDaysInTwoDates(strDateA : String , strDateB : String)-> Double{
        let previousDate = strDateA
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
       
        let previousDateFormated : Date? = dateFormatter.date(from: previousDate)
        
        let futureDate = strDateB
        let futureDateFormatted : Date? = dateFormatter.date(from: futureDate)
        let differenceInDays = (futureDateFormatted?.timeIntervalSince(previousDateFormated!))! / (60 * 60 * 24)

        
        return differenceInDays
    }
}


extension Notification.Name {
    static let imageDownloaded = Notification.Name(
        rawValue: "imageDownloaded")
}
*/
