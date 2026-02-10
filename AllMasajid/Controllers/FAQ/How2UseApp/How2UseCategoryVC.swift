//
//  How2UseCategoryVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import SafariServices
import SwiftyJSON
import PKHUD

class How2UseCategoryVC: UIViewController {
    
//    var myArr = [How2UseAppCategories]()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension How2UseCategoryVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HTUDataBank.item.count//myArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "DailyDuasTVC", for: indexPath) as! DailyDuasTVC
//        cell.setupHow2UseAppCell(model: myArr[indexPath.row])
        cell.setupHow2UseAppCell2(title: HTUDataBank.item[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadHow2UseDetailScreen()
        
        vc.imageNameReceived = HTUDataBank.item[indexPath.row].image
        vc.descriptionReceived = HTUDataBank.item[indexPath.row].description
        
        vc.titleReceived = HTUDataBank.item[indexPath.row].title//myArr[indexPath.row].display_name
        vc.screenName = HTUDataBank.item[indexPath.row].title//myArr[indexPath.row].name
        vc.screen = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension How2UseCategoryVC {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        myTableView.register(UINib(nibName: "DailyDuasTVC", bundle: nil), forCellReuseIdentifier: "DailyDuasTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
//        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

/*
extension How2UseCategoryVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        APIRequestUtil.GetHow2UseCategories(headers: [:], completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            myArr.removeAll()
            
            for index in 0..<json.count{
                let model = How2UseAppCategories(fromJson: json[index])
                myArr.append(model)
            }
            
            myArr.sort{ $0.order < $1.order }
            myTableView.reloadData()
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}
*/
