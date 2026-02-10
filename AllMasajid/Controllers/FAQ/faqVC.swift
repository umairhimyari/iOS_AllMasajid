//
//  faqVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 30/04/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

class faqVC: UIViewController {
    
    var screen = ""
    var titleStr = ""
    
    var faqArray = [FaqsModel]()

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var noRecordLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension faqVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "FaqTVC", for: indexPath) as! FaqTVC
        cell.questionLabel.text = faqArray[indexPath.row].question
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadFaqDetailScreen()
        vc.question = faqArray[indexPath.row].question
        vc.answer = faqArray[indexPath.row].answer
        vc.titleReceived = titleStr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension faqVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        faqArray.removeAll()
        HUD.show(.progress)
        APIRequestUtil.GetFAQs(screenName: screen, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)

            var seenQuestions = Set<String>()
            for index in 0..<json.count{
                let model = FaqsModel(fromJson: json[index])
                // filter duplicates
                let questionKey = model.question.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !questionKey.isEmpty && !seenQuestions.contains(questionKey) {
                    seenQuestions.insert(questionKey)
                    faqArray.append(model)
                }
            }

            noRecordLBL.isHidden = faqArray.count > 0
            noRecordLBL.text = "No FAQs available for this section."

            myTableView.reloadData()

        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}

extension faqVC {
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        
        titleLBL.text = titleStr
        myTableView.register(UINib(nibName: "FaqTVC", bundle: nil), forCellReuseIdentifier: "FaqTVC")
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
}
