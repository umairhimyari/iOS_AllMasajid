//
//  DisplayIqamahVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/11/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class DisplayIqamahVC: UIViewController {
    
    var iqamahArray = [DisplayIqamahModel]()
    var iqamahFilterArray = [DisplayIqamahModel]()

    var myStr = ""
    
    var masjidIDReceived = ""
    var masjidName = ""
    var address = ""
    
    var todaysDate = 0

    @IBOutlet weak var mosqueNameLBL: UILabel!
    @IBOutlet weak var addressLBL: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var dateLBL: UILabel!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var currentDateLBL: UILabel!
    
    @IBOutlet weak var mySegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @IBAction func threeDotBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item4"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterBtnPressed(_ sender: UIButton) {
        blackView.isHidden = false
        menuView.isHidden = false
    }
    
    @IBAction func segmentPressed(_ sender: UISegmentedControl) {
        switch mySegment.selectedSegmentIndex{
        case 0:
            one2Ten()
            myTableView.reloadData()
            break
            
        case 1:
            elev2Twenty()
            myTableView.reloadData()
            break
            
        case 2:
            twenty2End()
            myTableView.reloadData()
            break
            
        default:
            break
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        blackView.isHidden = true
        menuView.isHidden = true
    }
}

extension DisplayIqamahVC: ThreeDotProtocol {
    func addBtnPressed() {
        print("Do Nothing")
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
        networkHit()
    }
    
    func shareBtnPressed() {
        shareData()
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
}

extension DisplayIqamahVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iqamahFilterArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        if indexPath.row == iqamahFilterArray.count{
            let bottomCell = myTableView.dequeueReusableCell(withIdentifier: "DisplayIqamahBottomTVC", for: indexPath) as! DisplayIqamahBottomTVC
            bottomCell.textLBL.text = myStr
            
            cell = bottomCell
        }else{
            let topCell = myTableView.dequeueReusableCell(withIdentifier: "DisplayIqamahTVC", for: indexPath) as! DisplayIqamahTVC
            topCell.configureCell(item: iqamahFilterArray[indexPath.row])
            cell = topCell
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = 0
        if indexPath.row == iqamahFilterArray.count {
            height = 85
        }else{
            height = 50
        }
        
        return CGFloat(height)
    }
}

extension DisplayIqamahVC{
    
    func setupInitials(){
        
        mosqueNameLBL.text = masjidName
        addressLBL.text = address
        
        blackView.isHidden = true
        menuView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "DisplayIqamahTVC", bundle: nil), forCellReuseIdentifier: "DisplayIqamahTVC")
        myTableView.register(UINib(nibName: "DisplayIqamahBottomTVC", bundle: nil), forCellReuseIdentifier: "DisplayIqamahBottomTVC")
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"

        let now = Date()
        todaysDate = Int(formatter.string(from:now)) ?? 0
        print(todaysDate)
        networkHit()
    }
    
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func one2Ten(){
        mySegment.selectedSegmentIndex = 0
        currentDateLBL.text = "Showing Days 1 - 10"
        dateLBL.text = "Date (1-10)"
        
        if iqamahArray.count > 9 {
            iqamahFilterArray.removeAll()
            for j in 0..<10{
                iqamahFilterArray.append(iqamahArray[j])
            }
        }
    }
    
    func elev2Twenty(){
        mySegment.selectedSegmentIndex = 1
        currentDateLBL.text = "Showing Days 11 - 20"
        dateLBL.text = "Date (11-20)"
        
        if iqamahArray.count > 19 {
            iqamahFilterArray.removeAll()
            for j in 0..<10{
                iqamahFilterArray.append(iqamahArray[j + 10])
            }
        }
    }
    
    func twenty2End(){
        mySegment.selectedSegmentIndex = 2
        currentDateLBL.text = "Showing Days 21 - \(iqamahArray.count)"
        dateLBL.text = "Date (21-\(iqamahArray.count))"
        
        iqamahFilterArray.removeAll()
        for j in 0..<iqamahArray.count{
            let count = j + 20
            if count < iqamahArray.count {
                iqamahFilterArray.append(iqamahArray[j + 20])
            }
        }
    }
    
    func shareData(){
        
        var text2Share = "****** allMasajid - IQAMAH ******\n"

        for i in 0..<iqamahFilterArray.count {
            text2Share = text2Share + "\n\nDate: \(iqamahFilterArray[i].date)\nFajr: \(iqamahFilterArray[i].fajr)\nDuhr: \(iqamahFilterArray[i].duhr)\nAsr: \(iqamahFilterArray[i].asr)\nMagrib: \(iqamahFilterArray[i].maghrib) min/s after adhan\nIsha'a: \(iqamahFilterArray[i].isha)"
        }
        
        text2Share = text2Share + "\n\nPerforming salah with Jamaat is a hundred times better than performing alone. Get yourself benefited with the precise and reliable Iqamah timings by allMasajid so, you never run behind the Jamaat timings./nFor Android: https://bit.ly/2zCeFwM/nFor IOS: https://apple.co/2zHQXzo/nDownload the app to get exclusive Islamic services."
        
        let shareAll = [text2Share] as [Any]
        
        let activity = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activity.excludedActivityTypes = []

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            activity.popoverPresentationController?.sourceView = self.footerView
            activity.popoverPresentationController?.sourceRect = self.view.bounds
        }
    
        self.present(activity, animated: true, completion: nil)
    }
}

extension DisplayIqamahVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        APIRequestUtil.GetDisplayIqamah(id: "\(masjidIDReceived)", headers: [:], completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            let json = JSON(response)
            print(json)
            
            iqamahArray.removeAll()
            
            let data = json["data"].arrayValue
            for i in 0..<data.count{
                let date = data[i]["date"].stringValue
                
                let date2 = date.components(separatedBy: "-")
                let today = Int(date2[2]) ?? 0
                
                var todayStatus = false
                if today == todaysDate{
                    todayStatus = true
                }
                print("today: \(today) todayLCL: \(todaysDate), Status: \(todayStatus)")
                
                let fajr = data[i]["fajr"]
                var fajrTime = "-"
                if fajr != ""{
                    fajrTime = fajr["time"].stringValue
                }
                
                let duhr = data[i]["duhr"]
                var duhrTime = "-"
                if duhr != ""{
                    duhrTime = duhr["time"].stringValue
                }
                
                let asr = data[i]["asr"]
                var asrTime = "-"
                if asr != ""{
                    asrTime = asr["time"].stringValue
                }
                
                let maghrib = data[i]["maghrib"]
                var maghribTime = "-"
                if maghrib != ""{
                    maghribTime = maghrib["minutes"].stringValue
                }
                
                let isha = data[i]["isha"]
                var ishaTime = "-"
                if isha != ""{
                    ishaTime = isha["time"].stringValue
                }
                
                
                let model = DisplayIqamahModel(date: date, fajr: fajrTime, duhr: duhrTime, asr: asrTime, maghrib: maghribTime, isha: ishaTime, todayDay: today, todayStatus: todayStatus)
                iqamahArray.append(model)
            }
            
            for i in 0..<iqamahArray.count{
                if iqamahArray[i].todayStatus == true {
                    
                    if iqamahArray[i].todayDay > 0 && iqamahArray[i].todayDay < 11 {
                        one2Ten()
                    }else if iqamahArray[i].todayDay > 10 && iqamahArray[i].todayDay < 21 {
                        elev2Twenty()
                    }else{
                        twenty2End()
                    }
                }
            }
            
            let jummah = json["jummah"].arrayValue
            
            for i in 0..<jummah.count{
                if myStr == ""{
                    myStr = jummah[i]["time"].stringValue
                }else if i == jummah.count - 1 {
                    myStr = myStr + " & " + jummah[i]["time"].stringValue
                }else {
                    myStr = myStr + ", " + jummah[i]["time"].stringValue
                }
            }
            
            myTableView.reloadData()
            HUD.hide()
        }else{
            HUD.hide()
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
