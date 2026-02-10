//
//  SingleDuaVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/11/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SafariServices

class SingleDuaVC: UIViewController {
    
    var name: String = ""
    var duaArabic = ""
    var translation = ""
    var translation2 = ""
    var titleDua = ""
    var ref = ""

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
        vc.screen = "item6"
        self.parent?.present(vc, animated: false, completion: nil)
    }
}


extension SingleDuaVC: ThreeDotProtocol {
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "dua"
        vc.titleStr = "Duaas/Supplications"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func favouritesBtnPressed(){
        if UserDefaults.standard.bool(forKey: "isLoggedIn") != true{
            HUD.flash(.label("You must be logged in to see your favourites"), delay: 0.8)
        }else{
            let vc = UIStoryboard().LoadFavouriteDuasScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        print("Do Nothing")
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

extension SingleDuaVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        myTableView.rowHeight = UITableView.automaticDimension
        let cell = myTableView.dequeueReusableCell(withIdentifier: "SingleDuaTVC", for: indexPath) as! SingleDuaTVC
        
        cell.duaTitleLBL.text = titleDua == "" ? "-": titleDua
        cell.duaLBL.text = duaArabic == "" ? "-": duaArabic
        cell.translationLBL.text = translation == "" ? "-": translation
        cell.translation2LBL.text = translation2 == "" ? "-": translation2
        cell.referenceLBL.text = ref == "" ? "[ No Reference ]": "[\(ref)]"
        
        return cell
    }
}

extension SingleDuaVC{
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "SingleDuaTVC", bundle: nil), forCellReuseIdentifier: "SingleDuaTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        titleLabel.text = name
        myTableView.reloadData()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func shareData(){
        
        var text2Share = "****** allMasajid - Duua ******\n\n"
        
        text2Share = text2Share + "- Title: \(titleDua)\n\n- Duaa: \(duaArabic)\n\n English Translation:\n \(translation)\n\n- Translation:\n \(translation2)\n\n- Reference: \(ref = ref == "" ? "No Reference" : ref)"
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

