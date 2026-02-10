//
//  FeedbackViewController.swift
//  AllMasajid
//
//  Created by Malik Javed Iqbal on 22/12/2019.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class FeedbackViewController: UIViewController {
    
    var rating: Int = 1
    var messageStr = ""
    var emailPhoneStr = ""
    
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var tvFeedback: UITextView!
    
    @IBOutlet weak var txtEmailORPhone: UITextField!
    @IBOutlet weak var btnRating5: UIButton!
    @IBOutlet weak var btnRating4: UIButton!
    @IBOutlet weak var btnRating3: UIButton!
    @IBOutlet weak var btnRating2: UIButton!
    @IBOutlet weak var btnRating1: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvFeedback.delegate = self
        txtEmailORPhone.delegate = self
        setupTextViewInitials()
        btnRating1.isSelected = true

        // Set placeholder using native UITextField placeholder property
        txtEmailORPhone.placeholder = "Your Email"
        txtEmailORPhone.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )

        // Only set email if user has one, otherwise leave empty to show placeholder
        if !userEmail.isEmpty {
            txtEmailORPhone.text = userEmail
            txtEmailORPhone.textColor = UIColor.white
        } else {
            txtEmailORPhone.text = ""
            txtEmailORPhone.textColor = UIColor.white
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        footerView.addGestureRecognizer(tap)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toggleRating(_ sender: UIButton) {
        
        rating = sender.tag
        
        switch sender.tag {
        case 1:
            btnRating1.isSelected = true
            btnRating2.isSelected = false
            btnRating3.isSelected = false
            btnRating4.isSelected = false
            btnRating5.isSelected = false
            
            
        case 2:
            btnRating1.isSelected = true
            btnRating2.isSelected = true
            btnRating3.isSelected = false
            btnRating4.isSelected = false
            btnRating5.isSelected = false
            
        case 3:
            btnRating1.isSelected = true
            btnRating2.isSelected = true
            btnRating3.isSelected = true
            btnRating4.isSelected = false
            btnRating5.isSelected = false
        case 4:
            btnRating1.isSelected = true
            btnRating2.isSelected = true
            btnRating3.isSelected = true
            btnRating4.isSelected = true
            btnRating5.isSelected = false
            
        case 5:
            btnRating1.isSelected = true
            btnRating2.isSelected = true
            btnRating3.isSelected = true
            btnRating4.isSelected = true
            btnRating5.isSelected = true
            
        default:
            btnRating1.isSelected = true
        }
    }
    
    @IBAction func submitFeedback(_ sender: UIButton) {
        
        messageStr = tvFeedback.text == "Give us your feedback.." ? "" : tvFeedback.text!
        emailPhoneStr = txtEmailORPhone.text ?? ""
        
        if messageStr != "" && emailPhoneStr != ""{
            if emailPhoneStr.isValidEmail(){
                networkHit()
            }else{
                HUD.flash(.label("Please Enter Valid Email"), delay: 0.7)
            }
            
        }else{
            HUD.flash(.label("Please Enter Email & feedback To Continue"), delay: 0.7)
        }
    }
}

extension FeedbackViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func setupTextViewInitials(){
        if tvFeedback.text.isEmpty{
            tvFeedback.text = "Give us your feedback.."
            tvFeedback.textColor = UIColor.lightGray
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = "Give us your feedback.."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Native placeholder handles this automatically
        textField.textColor = UIColor.white
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Native placeholder handles empty state automatically
        textField.textColor = UIColor.white
    }
}

extension FeedbackViewController {
    
    func networkHit(){
        
        HUD.show(.progress)
        self.view.isUserInteractionEnabled = false

        let parameters = ["rating":"\(rating)", "email" : "\(txtEmailORPhone.text!)" ,"contact": "\(txtEmailORPhone.text!)", "message": "\(tvFeedback.text!)", "device": "2"]
        APIRequestUtil.SendFeedback(parameters: parameters, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        
        if let response = response{
            self.view.isUserInteractionEnabled = true
            HUD.hide()
            let json = JSON(response)
            print(json)
            
            let dic = json.dictionary
            let firstResponseKey = dic?.first?.key

            if firstResponseKey == "message"{
//                let message = json["message"].stringValue
                HUD.flash(.success, delay: 0.7){finished in
                    self.navigationController?.popViewController(animated: true)
                }
            }
                        
        }else{
            HUD.hide()
            self.view.isUserInteractionEnabled = true
            HUD.flash(.labeledError(title: "Message", subtitle: "Network Faliure!"), delay: 0.7)
        }
    }
}
