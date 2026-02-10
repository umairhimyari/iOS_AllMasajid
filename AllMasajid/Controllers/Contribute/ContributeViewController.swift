//
//  ContributeViewController.swift
//  AllMasajid
//
//  Created by Malik Javed Iqbal on 24/03/2020.
//  Copyright © 2020 Shahriyar Memon. All rights reserved.
//

import UIKit
import PKHUD
import SafariServices
//import Stripe

class ContributeViewController: UIViewController {//STPAddCardViewControllerDelegate
   
    @IBOutlet var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.footerView.addGestureRecognizer(tap)
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func contributeShare(_ sender: Any) {
        shareData()
    }
    
    @IBAction func contributeTime(_ sender: Any) {
        let vc = UIStoryboard().LoadContributeTimeScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func contributeMoney(_ sender: Any) {
//        let config = STPPaymentConfiguration()
//        config.requiredBillingAddressFields = .full
//        let viewController = STPAddCardViewController(configuration: config, theme: STPTheme.defaultTheme)
//        viewController.delegate = self
//        let navigationController = UINavigationController(rootViewController: viewController)
//        present(navigationController, animated: true, completion: nil)
        
//        let vc = UIStoryboard().LoadPaymentScreen()
//        self.navigationController?.pushViewController(vc, animated: true)
        
        HUD.flash(.label("Coming Soon Insha Allah"))
//        let vc = UIStoryboard().LoadContributeMoneyScreen()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func contributeSkills(_ sender: Any) {
        let vc = UIStoryboard().LoadContributeSkillsScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//extension ContributeViewController {
//    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
//        print("I am in 1")
//    }
//
//    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
//        print("Stripe Token = \(token)")
//    }
//    
//    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
//        print("I am in 2")
//        print(paymentMethod)
//        print("----")
//        print(STPToken.self)
//    }
//}

extension ContributeViewController: ThreeDotProtocol {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "contribute"
        vc.titleStr = "Contribute"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpBtnPressed(){
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func refreshBtnPressed() {
        print("Do nothing")
    }
    
    func shareBtnPressed() {
        print("Do nothing")
    }
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension ContributeViewController {
    
    func shareData(){
        
        let text2Share = "Do you wish to empower the Masjids and Muslim community through charity or welfare work? Join hands with allMasajid to contribute through your skills, time, and money to stabilize the Muslim organization./nFor Android: https://bit.ly/2zCeFwM/nFor IOS: https://apple.co/2/nDownload the app, and Register to contribute in the Masjid cause."
        
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
