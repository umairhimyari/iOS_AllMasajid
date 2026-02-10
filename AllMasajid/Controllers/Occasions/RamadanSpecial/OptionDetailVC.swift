//
//  OptionDetailVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 19/09/2022.
//  Copyright © 2022 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SafariServices

class OptionDetailVC: UIViewController {
    
    var screenName: SelectableOptionsScreen = .hadith
    var hadithArr = [HadithModel]()
    var benefitsArr = [BenefitsModel]()
    
    var name: String = ""
    var duaArabic = ""
    var translation = ""
    var translation2 = ""
    var titleDua = ""
    var ref = ""

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension OptionDetailVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        myTableView.rowHeight = UITableView.automaticDimension
        
        if screenName == .hadith {
            let cell = myTableView.dequeueReusableCell(withIdentifier: "SingleDuaTVC", for: indexPath) as! SingleDuaTVC
            cell.configureHadithCell(item: hadithArr[indexPath.row])
            return cell
        } else {
            let cell = myTableView.dequeueReusableCell(withIdentifier: "SimpleTextTVC", for: indexPath) as! SimpleTextTVC
            cell.configure(txt: benefitsArr[indexPath.row].description)
            return cell
        }
    }
}

extension OptionDetailVC{
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "SingleDuaTVC", bundle: nil), forCellReuseIdentifier: "SingleDuaTVC")
        myTableView.register(UINib(nibName: "SimpleTextTVC", bundle: nil), forCellReuseIdentifier: "SimpleTextTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        titleLabel.text = screenName.rawValue.capitalized
        subTitleLBL.text = !benefitsArr.isEmpty ? benefitsArr.first?.title : "Special Hadeeth For Ramadan"

        myTableView.reloadData()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let url = URL(string: allMWebURL)
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
}

