//
//  FavouriteDuasVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 25/07/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices
import Alamofire

class FavouriteDuasVC: UIViewController {

    var duasArr = [DuasModel]()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var noRecordLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item4"
        self.parent?.present(vc, animated: false, completion: nil)
    }
}

extension FavouriteDuasVC: ThreeDotProtocol {
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
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
        shareData()
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension FavouriteDuasVC: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return duasArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        myTableView.rowHeight = UITableView.automaticDimension
        let cell = myTableView.dequeueReusableCell(withIdentifier: "DuasTVC", for: indexPath) as! DuasTVC
        cell.favoruiteBtn.setImage(#imageLiteral(resourceName: "heart-green"), for: .normal)
        
        cell.duaLabel.text = duasArr[indexPath.row].dua == "" ? "-": duasArr[indexPath.row].dua
        cell.duaReasonLabel.text = duasArr[indexPath.row].name == "" ? "-": duasArr[indexPath.row].name
        cell.translationLabel.text = duasArr[indexPath.row].translation == "" ? "-": duasArr[indexPath.row].translation
        cell.translation2Label.text = duasArr[indexPath.row].second_translation == "" ? "-": duasArr[indexPath.row].second_translation
        
        cell.favoruiteBtn.addTarget(self, action: #selector(removeFavourite), for: .touchUpInside)
        cell.favoruiteBtn.tag = duasArr[indexPath.row].id
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadSingleDuasScreen()
        vc.name = "Favourites"
        vc.duaArabic = duasArr[indexPath.row].dua
        vc.translation = duasArr[indexPath.row].translation
        vc.translation2 = duasArr[indexPath.row].second_translation
        vc.titleDua = duasArr[indexPath.row].name
        vc.ref = duasArr[indexPath.row].reference
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func removeFavourite(sender: UIButton){
        networkHitUnFavourite(id: sender.tag)
    }
}

extension FavouriteDuasVC{
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "DuasTVC", bundle: nil), forCellReuseIdentifier: "DuasTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func shareData(){
        
        var text2Share = "****** allMasajid - My Favourite Duaas ******\n\n"
        
        for key in 0..<duasArr.count {
            let dua = duasArr[key].dua
            text2Share = text2Share + "- \(dua)\n"
        }
        
        text2Share = text2Share + "\n\nرَبَّنَا وَسِعْتَ كُلَّ شَيْءٍ رَّحْمَةً وَعِلْمًا فَاغْفِرْ لِلَّذِينَ تَابُوا وَاتَّبَعُوا سَبِيلَكَ وَقِهِمْ عَذَابَ الْجَحِيمِ\n\"Our Lord! You hast enclosed everything in mercy and knowledge. Pardon those who repent and follow Your way and protect them from Hellfire punishment.\"(Surah Ghafir - 40:7)\nMay Allah forgive our sins and protect us from afterlife punishments.\nTo browse daily duaas, hadith, and Islamic updates. Download our app now.\nFor Android: https://bit.ly/2zCeFwM\nFor IOS: https://apple.co/2zHQXzo"
        
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

extension FavouriteDuasVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(myToken)", "translation": "urdu"]
        APIRequestUtil.GetFavouriteDuas(headers: headers, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            duasArr.removeAll()
            let dua = json["dua"].arrayValue
            
            for index in 0..<dua.count{
                let model = DuasModel(fromJson: dua[index])
                duasArr.append(model)
            }
            myTableView.reloadData()
            
            if duasArr.count == 0 {
                HUD.flash(.label("No Data Found"), delay: 0.7)
                noRecordLBL.isHidden = false
            }else{
                noRecordLBL.isHidden = true
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

extension FavouriteDuasVC{
    
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
            
            let dua = json["dua"].arrayValue
            duasArr.removeAll()
            
            for index in 0..<dua.count{
                let model = DuasModel(fromJson: dua[index])
                duasArr.append(model)
            }
            myTableView.reloadData()
            
            if duasArr.count == 0 {
                HUD.flash(.label("No Data Found"), delay: 0.7)
                noRecordLBL.isHidden = false
            }else{
                noRecordLBL.isHidden = true
            }
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}
