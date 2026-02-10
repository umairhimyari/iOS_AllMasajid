//
//  Request4DuasVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 04/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class Request4DuasVC: UIViewController {

    var last_page = 0
    var pageNo = 1
    var isRefreshing = false
    
    var duasArr = [DuaAppealsModel]()
    var myApealsArr = [DuaAppealsModel]()
    
    var selectedSegment = 1
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mySegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkHit(page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func segmentPressed(_ sender: UISegmentedControl) {
        switch mySegment.selectedSegmentIndex{
        case 0:
            selectedSegment = 1
            refreshBtnPressed()
            break
            
        case 1:
            selectedSegment = 2
            
            if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
                duasArr.removeAll()
                myTableView.reloadData()
                HUD.flash(.label("Please login to enjoy this feature"), delay: 0.7)
                
            }else{
                myApealsArr.removeAll()
                networkHitUser(page: 1)
                myTableView.reloadData()
            }
            
            break
            
        default:
            break
        }
    }
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item1"
        self.parent?.present(vc, animated: false, completion: nil)
    }
}

extension Request4DuasVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        let vc = UIStoryboard().LoadAddDuaRequestScreen()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "dua_appeals"
        vc.titleStr = "Dua Appeals"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        pageNo = 1
        selectedSegment = 1
        mySegment.selectedSegmentIndex = 0
        duasArr.removeAll()
        myApealsArr.removeAll()
        networkHit(page: 1)
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

extension Request4DuasVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSegment == 1 ? duasArr.count : myApealsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedSegment == 1 {
            let cell = myTableView.dequeueReusableCell(withIdentifier: "Request4DuasTVC", for: indexPath) as! Request4DuasTVC
            cell.configureCell(item: duasArr[indexPath.row])
            return cell
        }else{
            let cell = myTableView.dequeueReusableCell(withIdentifier: "UserRequest4DuasTVC", for: indexPath) as! UserRequest4DuasTVC
            cell.removeBTN.tag = myApealsArr[indexPath.row].id
            cell.extendBTN.tag = myApealsArr[indexPath.row].id
            cell.editBTN.tag = myApealsArr[indexPath.row].id
            cell.removeBTN.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
            cell.extendBTN.addTarget(self, action: #selector(extendBtnPressed(sender:)), for: .touchUpInside)
            cell.editBTN.addTarget(self, action: #selector(editBtnPressed(sender:)), for: .touchUpInside)
            cell.configureCell(item: myApealsArr[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadRequest4DuaDetailScreen()
        vc.idReceived = selectedSegment == 1 ? duasArr[indexPath.row].id : myApealsArr[indexPath.row].id
//        vc.emailTxt = selectedSegment == 1 ? duasArr[indexPath.row].email : myApealsArr[indexPath.row].email
//        vc.contactTxt = selectedSegment == 1 ? duasArr[indexPath.row].contact_no : myApealsArr[indexPath.row].contact_no
//        vc.nameTxt = selectedSegment == 1 ? duasArr[indexPath.row].user_name : myApealsArr[indexPath.row].user_name
//        vc.titleTxt = selectedSegment == 1 ? duasArr[indexPath.row].title : myApealsArr[indexPath.row].title
//        vc.appealTxt = selectedSegment == 1 ? duasArr[indexPath.row].appeal : myApealsArr[indexPath.row].appeal
//        vc.status = selectedSegment == 1 ? duasArr[indexPath.row].is_secret : myApealsArr[indexPath.row].is_secret
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedSegment == 1 ? 95 : 130
    }
    
    @objc func removeBtnPressed(sender: UIButton){
        networkHitUserRemoveApeal(id: sender.tag)
    }
    
    @objc func extendBtnPressed(sender: UIButton){
        networkHitUserExtendApeal(id: sender.tag)
    }
    
    @objc func editBtnPressed(sender: UIButton){
        let vc = UIStoryboard().LoadAddDuaRequestScreen()
        vc.delegate = self
        vc.idReceived = sender.tag
        vc.isEdit = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension Request4DuasVC: RefreshProtocol {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "Request4DuasTVC", bundle: nil), forCellReuseIdentifier: "Request4DuasTVC")
        myTableView.register(UINib(nibName: "UserRequest4DuasTVC", bundle: nil), forCellReuseIdentifier: "UserRequest4DuasTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let now = Date()
        let dateString = formatter.string(from:now)
        dateLabel.text = dateString
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
        let count = Int(last_page)
        
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isRefreshing) {
            
            isRefreshing = true
            if pageNo < count {
                pageNo = pageNo + 1
                if selectedSegment == 1 {
                    networkHit(page: pageNo)
                }else{
                    networkHitUser(page: pageNo)
                }
            }
        }
    }
    
    func refresh() {
        refreshBtnPressed()
    }
}

extension Request4DuasVC: TryAgainProtocol{
    
    func tryAgain() {
        refreshBtnPressed()
    }
    
    func networkHit(page: Int){
        HUD.show(.progress)
        APIRequestUtil.DisplayAppeals(page: page, headers: [:], completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            last_page = json["last_page"].intValue
            
            let data = json["data"].arrayValue
                        
            for index in 0..<data.count{
                let model = DuaAppealsModel(fromJson: data[index])
                duasArr.append(model)
            }
            myTableView.reloadData()
            
            if duasArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            
            isRefreshing = false
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension Request4DuasVC {
    
    func networkHitUser(page: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.DisplayUserAppeals(page: page, headers: httpHeaders, completion: APIRequestUserCompleted)
    }
    
    func networkHitUserRemoveApeal(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.DeleteAppeal(id: id, headers: httpHeaders, parameters: [:], completion: APIRequestUserRemoveApealCompleted)
    }
    
    func networkHitUserExtendApeal(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.ExtendAppeal(id: id, parameters: [:], headers: httpHeaders, completion: APIRequestUserRemoveApealCompleted)
    }
    
    fileprivate func APIRequestUserCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            last_page = json["last_page"].intValue
            let data = json["data"].arrayValue
                        
            for index in 0..<data.count{
                let model = DuaAppealsModel(fromJson: data[index])
                myApealsArr.append(model)
            }
            myTableView.reloadData()
            
            if myApealsArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            isRefreshing = false
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
    
    fileprivate func APIRequestUserRemoveApealCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            myApealsArr.removeAll()
            networkHitUser(page: 1)
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
