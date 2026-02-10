//
//  ViewControllerExtension.swift
//  Hawksavvy
//
//  Created by 12345 on 9/17/18.
//  Copyright © 2018 Shahriyar Memon. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIViewController {
    
    func removeNotification(identifier : String){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            var identifiers: [String] = []
            
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier == identifier {
                    identifiers.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func setNotification(identifier : String, time : String){
        let center = UNUserNotificationCenter.current()
        
        let dateFormatter : DateFormatter = DateFormatter()
        let comp = time.components(separatedBy: " ")
        
        let content = UNMutableNotificationContent()
      
        if (defaults.integer(forKey: "Time Format")) == 0 {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            content.title = "\(comp[1]) \(comp[2]) \(identifier)"
        }
        else{
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            content.title = "\(comp[1]) \(identifier)"
        }
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.defaultCritical
        } else {
            // Fallback on earlier versions
            content.sound = UNNotificationSound.default
        }
        let date = Date()
        let result = dateFormatter.string(from: date)
        
        let currentDate = dateFormatter.date(from: result)
        var namazDate = dateFormatter.date(from: time)
        var interval = namazDate?.timeIntervalSince(currentDate!)
        if interval! < 0.0 {
            namazDate = NSCalendar.current.date(byAdding: .day, value: 1, to: namazDate!)
            interval = namazDate?.timeIntervalSince(currentDate!)
        }
        
        var namazTitle = identifier
        if namazTitle == "MAGHRIB"{
            namazTitle = "MAGRIB"
        }else if namazTitle == "ISHRAAQ"{
            namazTitle = "ISHRAQ"
        }else if identifier == "ISHA" {
            namazTitle = "ISHA'A"
        }
        
        content.body = "It is time for \(namazTitle) prayers."
        content.sound = UNNotificationSound.default
        let components = NSCalendar.current.dateComponents([.hour,.minute], from: namazDate!)
        let alarmTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: alarmTrigger)
         
        center.add(request, withCompletionHandler: {(error) in
            print(error as Any)
        })
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
