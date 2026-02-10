//
//  NotificationsListVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

struct Notifications {
    var title = ""
    var body = ""
    var type = ""
    var image = ""
}

class NotificationsListVC: UIViewController {

    var last_page = 0
    var pageNo = 1
    var isRefreshing = false
    var notifications = [Notifications]()
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkHit(page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension NotificationsListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "NotificationsListTVC", for: indexPath) as! NotificationsListTVC
        print("+++++")
        print(indexPath.row)
        cell.titleLBL.text = notifications[indexPath.row].title == "" ? "N/A" : notifications[indexPath.row].title
        cell.bodyLBL.text = notifications[indexPath.row].body == "" ? "N/A" : notifications[indexPath.row].body
        cell.typeLBL.text = "Type:" + notifications[indexPath.row].type
        if let url = URL(string: notifications[indexPath.row].image) {
            GetImage.getImage(url: url, image: cell.myIMG)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

extension NotificationsListVC {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "NotificationsListTVC", bundle: nil), forCellReuseIdentifier: "NotificationsListTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func refreshBtnPressed() {
        pageNo = 1
        notifications.removeAll()
        networkHit(page: 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
        let count = Int(last_page)
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isRefreshing) {
            
            isRefreshing = true
            if pageNo < count {
                pageNo = pageNo + 1
                networkHit(page: pageNo)
            }
        }
    }
}

extension NotificationsListVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit(page: 1)
    }
    
    func networkHit(page: Int){
        HUD.show(.progress)
        APIRequestUtil.GetNotificationList(page: page, headers: httpHeaders, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            last_page = json["last_page"].intValue
            
            let data = json["data"].arrayValue
                        
            for i in 0..<data.count{
                let model = Notifications(title: data[i]["title"].stringValue, body: data[i]["push_text"].stringValue, type: data[i]["type"].stringValue, image: data[i]["image"].stringValue)
                notifications.append(model)
            }
            myTableView.reloadData()
            
            if notifications.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            
            isRefreshing = false
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}
