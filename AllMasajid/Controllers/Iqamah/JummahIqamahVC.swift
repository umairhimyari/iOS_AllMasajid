//
//  JummahIqamahVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 23/11/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SCLAlertView
import SafariServices

class JummahIqamahVC: UIViewController {
    
    var latReceived = ""
    var longReceived = ""
    var address = ""
    
    var model: IqamahNearByModel?

    @IBOutlet weak var footrView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var namazNameLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footrView.addGestureRecognizer(tap)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func setupInitials() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footrView.addGestureRecognizer(tap)
        
        addressLBL.text = address
        myTableView.register(UINib(nibName: "IqamahTVC", bundle: nil), forCellReuseIdentifier: "IqamahTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
    }
}

extension JummahIqamahVC: ThreeDotProtocol {
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "iqamah"
        vc.titleStr = "Iqamah"
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
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension JummahIqamahVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.jumah.count ?? 0//masajidList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "IqamahTVC", for: indexPath) as! IqamahTVC
        cell.masjidLBL.text = model?.jumah[indexPath.row].type
        cell.distanceLBL.text = "\(model?.distanceStr ?? "-")"
        cell.nextTimeLBL.isHidden = true
        cell.timeLBL.text = "\(model?.jumah[indexPath.row].time ?? "-")"
        
        let timeMinutes = model?.jumah[indexPath.row].diff_time_number ?? 0
        
        var timeMinutesStr = "-"
        if timeMinutes != 0{
            timeMinutesStr = "\(timeMinutes)"
        }
        
        cell.timeRemainingLBL.text = timeMinutesStr + " m"

        /*
        let dist = model?.distance ?? 0
        let unit = model?.units
        
        var meters = 0
        if unit == "M" {
            meters = Int((dist/0.6213) * 1000)
        }else if unit == "K"{
            meters = Int(dist * 1000)
        }
        
        // A person can travel 100 meters in 30 seconds
        let myFormula = (30 * meters)/100
        let myMinutes = myFormula / 60
        */
             
        let timeRequiredSec = model?.timeRequiredSeconds ?? 0
                
        if timeMinutes > (timeRequiredSec/60) {
            cell.isReachableVie.backgroundColor = #colorLiteral(red: 0.3490196078, green: 1, blue: 0, alpha: 1)
        }else if timeMinutes < (timeRequiredSec/60) {
            cell.isReachableVie.backgroundColor = .red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayAlert(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension JummahIqamahVC {
    
    func displayAlert(index:Int){
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "Avenir-Heavy", size: 18)!,
            kTextFont: UIFont(name: "Avenir-Heavy", size: 16)!,
            kButtonFont: UIFont(name: "Avenir-Heavy", size: 16)!,
            showCloseButton: true,
            showCircularIcon: false,
            titleColor:#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        )
        
        let item = MasjidItem()
        item.id = self.model?.googleMasjidID ?? ""
        item.name = self.model?.masjidName ?? ""
        item.location = self.model!.location
        item.distance = self.model!.distance
        
        let alert = SCLAlertView(appearance: appearance)
        
        _ = alert.addButton("Directions"){
            self.getDirectionsToMasjid(item: item)
        }
        
        let color = #colorLiteral(red: 0.05882352941, green: 0.4509803922, blue: 0.8274509804, alpha: 1)
        alert.showCustom("\(item.name)", subTitle: "", color: color, icon: #imageLiteral(resourceName: "logo"))

    }
    
    func getDirectionsToMasjid(item: MasjidItem){
        
        if (UIApplication.shared.canOpenURL(URL(string:"https://www.google.com/maps/")!)) {
            
            UIApplication.shared.open(URL(string:
                "https://www.google.com/maps?saddr=\(latReceived),\(longReceived)&daddr=\(item.location.coordinate.latitude),\(item.location.coordinate.longitude)")!, options: [:], completionHandler: nil)
        } else {
            let directionsURL = "http://maps.apple.com/?daddr=\(item.location.coordinate.latitude),\(item.location.coordinate.longitude)&t=m&z=10"
            guard let url = URL(string: directionsURL) else {
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//myLocation.coordinate.latitude
//myLocation.coordinate.longitude
