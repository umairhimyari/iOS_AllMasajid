//
//  RamadanSpecialVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 19/09/2022.
//  Copyright © 2022 allMasajid. All rights reserved.
//

import UIKit

class RamadanSpecialVC: UIViewController {

    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func benefitsBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadSelectableOptionsScreen()
        vc.screenName = .benefits
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func hadithBtnPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadSelectableOptionsScreen()
        vc.screenName = .hadith
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

extension RamadanSpecialVC: ThreeDotProtocol {
    
    func refreshBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "ramadan"
        vc.titleStr = "Ramadan Special"
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

extension RamadanSpecialVC {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func setupInitials(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
    }
}

