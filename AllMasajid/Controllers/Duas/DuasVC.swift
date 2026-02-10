//
//  DuasVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices
import Alamofire

class DuasVC: UIViewController {
    
    var id = ""
    var name = ""
    var duasArr = [DuasModel]()

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
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
}

extension DuasVC: ThreeDotProtocol {
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
        print("Do nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension DuasVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return duasArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        myTableView.rowHeight = UITableView.automaticDimension
        let cell = myTableView.dequeueReusableCell(withIdentifier: "DuasTVC", for: indexPath) as! DuasTVC
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn")==true{
            let fav = duasArr[indexPath.row].fav
            if fav == 0 {
                cell.favoruiteBtn.setImage(#imageLiteral(resourceName: "heart-grey"), for: .normal)
                cell.favoruiteBtn.addTarget(self, action: #selector(favouriteBtnPressed), for: .touchUpInside)
            }else if fav == 1{
                cell.favoruiteBtn.setImage(#imageLiteral(resourceName: "heart-green"), for: .normal)
                cell.favoruiteBtn.addTarget(self, action: #selector(removeFavourite), for: .touchUpInside)
            }
        }else{
            cell.favoruiteBtn.addTarget(self, action: #selector(loginAlert), for: .touchUpInside)
        }
        
        cell.favoruiteBtn.tag = duasArr[indexPath.row].id
        cell.duaLabel.text = duasArr[indexPath.row].dua == "" ? "-": duasArr[indexPath.row].dua
        cell.duaReasonLabel.text = duasArr[indexPath.row].name == "" ? "-": duasArr[indexPath.row].name
        cell.translationLabel.text = duasArr[indexPath.row].translation == "" ? "-": duasArr[indexPath.row].translation
        cell.translation2Label.text = duasArr[indexPath.row].second_translation == "" ? "-": duasArr[indexPath.row].second_translation
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadSingleDuasScreen()
        vc.name = name
        vc.duaArabic = duasArr[indexPath.row].dua
        vc.translation = duasArr[indexPath.row].translation
        vc.translation2 = duasArr[indexPath.row].second_translation
        vc.titleDua = duasArr[indexPath.row].name
        vc.ref = duasArr[indexPath.row].reference
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func favouriteBtnPressed(sender: UIButton) {
        networkHitMakeFavourite(id: sender.tag)
    }
    
    @objc func removeFavourite(sender: UIButton) {
        networkHitUnFavourite(id: sender.tag)
    }
    
    @objc func loginAlert(sender: UIButton){
        HUD.flash(.label("Please login to make duaas favourite"), delay: 0.7)
    }
}

extension DuasVC{
    
    func setupInitials() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "DuasTVC", bundle: nil), forCellReuseIdentifier: "DuasTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        titleLabel.text = name
        
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension DuasVC: TryAgainProtocol {
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){

        HUD.show(.progress)
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true{
            let headers: HTTPHeaders = ["Authorization": "Bearer \(myToken)", "translation": "urdu"]
            APIRequestUtil.GetDuasFromCategory(id: id, headers: headers, completion: APIRequestCompleted)
        }else{
            let headers: HTTPHeaders = ["translation": "urdu"]
            APIRequestUtil.GetDuasFromCategory(id: id, headers: headers, completion: APIRequestCompleted)
        }
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            let dua = json["dua"].arrayValue
            duasArr.removeAll()
            
            for index in 0..<dua.count{
                let model = DuasModel(fromJson: dua[index])
                duasArr.append(model)
            }
            myTableView.reloadData()
            
            if duasArr.count == 0 {
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

extension DuasVC{
    
    func networkHitMakeFavourite(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.MakeFavouriteDua(id: "\(id)", headers: httpHeaders, completion: APIRequestMakeFavouriteCompleted)
    }
    
    fileprivate func APIRequestMakeFavouriteCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            networkHit()
            
        }else{
            
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension DuasVC{
    
    func networkHitUnFavourite(id: Int){
        HUD.show(.progress)
//        let headers = ["Authorization": "Bearer \(myToken)"]
        APIRequestUtil.RemoveFavouriteDua(id: "\(id)", headers: httpHeaders, completion: APIRequestUnFavouriteCompleted)
    }
    
    fileprivate func APIRequestUnFavouriteCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            networkHit()
        }else{
            
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
