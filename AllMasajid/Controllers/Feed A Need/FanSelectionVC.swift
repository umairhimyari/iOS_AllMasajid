//
//  FanSelectionVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 12/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class FanSelectionVC: UIViewController {

    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }

    @IBAction func masajidBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadFanMasajidScreen()
        self.navigationController?.pushViewController(vc, animated: true)
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
}


extension FanSelectionVC: ThreeDotProtocol {
    
    func refreshBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "feedaneed"
        vc.titleStr = "Feed A Need"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
}

extension FanSelectionVC {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
    }
}

