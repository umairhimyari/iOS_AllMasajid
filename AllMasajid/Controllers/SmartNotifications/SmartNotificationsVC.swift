//
//  SmartNotificationsVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class SmartNotificationsVC: UIViewController {
    
    var events = 0
    var announcements = 0
    var duaaAppeals = 0
    var supplications = 0
    var iqamah = 0

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var eventsSwitch: UISwitch!
    @IBOutlet weak var announcementsSwitch: UISwitch!
    @IBOutlet weak var duaAppealsSwitch: UISwitch!
    @IBOutlet weak var supplicationsSwitch: UISwitch!
    @IBOutlet weak var iqamahSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        networkHitSetSetting()
    }
    
    @IBAction func prayerTimesPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadPrayerTimesScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func eventsSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            events = 1
        }else{
            events = 0
        }
    }
    
    @IBAction func announcementsSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            announcements = 1
        }else{
            announcements = 0
        }
    }
    
    @IBAction func duaAppealsSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            duaaAppeals = 1
        }else{
            duaaAppeals = 0
        }
    }
    
    @IBAction func supplicationsSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            supplications = 1
        }else{
            supplications = 0
        }
    }
    
    @IBAction func iqamahSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            iqamah = 1
        }else{
            iqamah = 0
        }
    }
}

extension SmartNotificationsVC {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension SmartNotificationsVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        APIRequestUtil.GetNotificationsSettings(headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    func networkHitSetSetting(){
        HUD.show(.progress)
        let parameters = ["events":"\(events)", "announcements":"\(announcements)", "dua_appeals":"\(duaaAppeals)", "supplications":"\(supplications)", "iqamah":"\(iqamah)"]
        APIRequestUtil.SetNotificationsSettings(parameters: parameters, headers: httpHeaders, completion: APIRequestSetSettingCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            duaaAppeals = json["dua_appeals"].intValue
            announcements = json["announcements"].intValue
            iqamah = json["iqamah"].intValue
            events = json["events"].intValue
            supplications = json["supplications"].intValue
            
            duaAppealsSwitch.setOn(duaaAppeals == 1, animated: true)
            announcementsSwitch.setOn(announcements == 1, animated: true)
            iqamahSwitch.setOn(iqamah == 1, animated: true)
            eventsSwitch.setOn(events == 1, animated: true)
            supplicationsSwitch.setOn(supplications == 1, animated: true)
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
    
    fileprivate func APIRequestSetSettingCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
        }else{
            HUD.flash(.labeledError(title: "Network Faliure", subtitle: "Something went wrong"), delay: 0.8)
        }
    }
}
