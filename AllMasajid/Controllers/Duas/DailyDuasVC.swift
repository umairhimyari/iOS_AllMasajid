//
//  DailyDuasVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import SafariServices

class DailyDuasVC: UIViewController {

    var selectedSegment = 1
    var duasArr = [DailyDuasModel]()
    
    @IBOutlet weak var mySegCtrl: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
        /*
        if UserDefaults.standard.bool(forKey: "introDuas") != true {
            UserDefaults.standard.set(true, forKey: "introDuas")
            let vc = UIStoryboard().LoadHow2UseDetailScreen()
            vc.titleReceived = "Duaas/Supplications"
            vc.screenName = "dua"
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item5"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func segmentCtrlPressed(_ sender: UISegmentedControl) {
        
        switch mySegCtrl.selectedSegmentIndex{
        case 0:
            selectedSegment = 1
            networkHit()
            myTableView.reloadData()
            break
            
        case 1:
            selectedSegment = 2
            networkHit()
            myTableView.reloadData()
            break
            
        case 2:
            selectedSegment = 3
            networkHit()
            myTableView.reloadData()
            break
            
        default:
            break
        }
    }
}

extension DailyDuasVC: ThreeDotProtocol {
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "dua"
        vc.titleStr = "Duaas/Supplications"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        selectedSegment = 1
        mySegCtrl.selectedSegmentIndex = 0
        networkHit()
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func favouritesBtnPressed(){
        print("Do Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension DailyDuasVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return duasArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "DailyDuasTVC", for: indexPath) as! DailyDuasTVC
        cell.titleLabel.text = duasArr[indexPath.row].name
        
        let image = duasArr[indexPath.row].image
        
        if image != ""{
            GetImage.getImage(url: URL(string: image)!, image: cell.myImageView)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadDuasScreen()
        vc.id = duasArr[indexPath.row].id
        vc.name = duasArr[indexPath.row].name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension DailyDuasVC{
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "DailyDuasTVC", bundle: nil), forCellReuseIdentifier: "DailyDuasTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" //"yyyy-MM-dd HH:mm:ss Z"
        let now = Date()
        let dateString = formatter.string(from:now)
        dateLabel.text = dateString
                
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension DailyDuasVC: TryAgainProtocol{
    
    func tryAgain() {
        refreshBtnPressed()
    }
    
    func networkHit(){
        HUD.show(.progress)
        APIRequestUtil.GetDuasCategories(id: "\(selectedSegment)", headers: [:], completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            duasArr.removeAll()
            let dua_sub_types = json["dua_sub_types"].arrayValue
            
            for index in 0..<dua_sub_types.count{
                let model = DailyDuasModel(fromJson: dua_sub_types[index])
                duasArr.append(model)
            }
            myTableView.reloadData()
            
            if duasArr.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
//            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
