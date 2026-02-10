//
//  SelectableOptionsVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 19/09/2022.
//  Copyright © 2022 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import SafariServices

enum SelectableOptionsScreen: String {
    case hadith, benefits
}

class SelectableOptionsVC: UIViewController {
    
    var screenName: SelectableOptionsScreen = .hadith
    var hadithArr = [HadithModel]()
    var benefitsArr = [BenefitsModel]()

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
}

extension SelectableOptionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenName == .hadith ? hadithArr.count : benefitsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        myTableView.rowHeight = UITableView.automaticDimension
        let cell = myTableView.dequeueReusableCell(withIdentifier: "DailyDuasTVC", for: indexPath) as! DailyDuasTVC
        cell.titleLabel.text = screenName == .hadith ? hadithArr[indexPath.row].title : benefitsArr[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadOptionDetailScreen()
        vc.screenName = screenName
        vc.hadithArr = hadithArr.isEmpty ? [] : [hadithArr[indexPath.row]]
        vc.benefitsArr = benefitsArr.isEmpty ? [] : [benefitsArr[indexPath.row]]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension SelectableOptionsVC {
    
    func setupInitials() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "DailyDuasTVC", bundle: nil), forCellReuseIdentifier: "DailyDuasTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        titleLabel.text = screenName.rawValue.capitalized
        networkHit()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

extension SelectableOptionsVC: TryAgainProtocol {
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit() {
        HUD.show(.progress)
        if screenName == .hadith {
            APIRequestUtil.GetRamadanHadith(headers: [:], completion: APIRequestCompleted)
        } else if screenName == .benefits {
            APIRequestUtil.GetRamadanBenefits(headers: [:], completion: APIRequestCompleted)
        }
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response {
            let json = JSON(response)
            print(json)
            
            if screenName == .benefits {
                benefitsArr.removeAll()
                let benefits = json["benefits"].arrayValue
                
                for index in 0..<benefits.count {
                    let model = BenefitsModel(fromJson: benefits[index])
                    benefitsArr.append(model)
                }
            } else if screenName == .hadith {
                hadithArr.removeAll()
                let hadiths = json["hadith"].arrayValue
                
                for index in 0..<hadiths.count {
                    let model = HadithModel(fromJson: hadiths[index])
                    hadithArr.append(model)
                }
            }
            
            if benefitsArr.isEmpty && hadithArr.isEmpty {
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
            
            myTableView.reloadData()
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}
