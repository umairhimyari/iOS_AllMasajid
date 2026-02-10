//
//  faqDetailVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/04/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import SafariServices

class faqDetailVC: UIViewController {
    
    var question = ""
    var answer = ""
    var titleReceived = ""

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
        setupGesture()
    }
    
    @objc func backToFaqTapped(_ sender: UITapGestureRecognizer? = nil) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension faqDetailVC {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        titleLBL.text = titleReceived
        buttonView.cornerRadius = 20
        topView.cornerRadius = 10
        bottomView.cornerRadius = 10
        
        questionLabel.text = question
        answerLabel.text = answer
    }
    
    func setupGesture() -> Void {
        let buttonTap = UITapGestureRecognizer(target: self, action: #selector(self.backToFaqTapped(_:)))
        buttonView.addGestureRecognizer(buttonTap)
    }

    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {

        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}
