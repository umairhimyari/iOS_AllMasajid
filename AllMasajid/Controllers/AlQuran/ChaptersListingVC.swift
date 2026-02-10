//
//  ChaptersListingVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import SwiftyJSON

class ChaptersListingVC: BaseVC {
    
    var parahArray = [Juzs]()
    var chaptersArray = [ChapterModel]()
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
        callChaptersAPI()
    }
    
    
    @IBAction func segmentCtrlPressed(_ sender: UISegmentedControl) {
        
        switch segmentControl.selectedSegmentIndex{
        case 0:
            if chaptersArray.isEmpty {
                callChaptersAPI()
            }
            tableView.reloadData()
            break
            
        case 1:
            if parahArray.isEmpty {
                callJuzAPI()
            }
            tableView.reloadData()
            break
            
        default:
            break
        }
    }
}

extension ChaptersListingVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? chaptersArray.count : parahArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuranChaptersListTVC", for: indexPath) as! QuranChaptersListTVC
        
        if segmentControl.selectedSegmentIndex == 0 {
            cell.setChapter(item: chaptersArray[indexPath.row])
        } else {
            cell.setJuz(item: parahArray[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard().LoadChapterDetail()
        
        if segmentControl.selectedSegmentIndex == 0 {
            vc.id = chaptersArray[indexPath.row].id
            vc.type = .chapter
        } else {
            vc.id = parahArray[indexPath.row].juzNumber
            vc.type = .juz
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChaptersListingVC: TryAgainProtocol {
    
    func setupInitials(){
        tableView.register(UINib(nibName: "QuranChaptersListTVC", bundle: nil), forCellReuseIdentifier: "QuranChaptersListTVC")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    func tryAgain() {
        if segmentControl.selectedSegmentIndex == 0 {
            callChaptersAPI()
        } else {
            callJuzAPI()
        }
    }
    
    func showEmptyVu() {
        let vc = UIStoryboard().LoadTryAgainScreen()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.parent?.present(vc, animated: false, completion: nil)
    }
}


extension ChaptersListingVC {
    func callChaptersAPI(){
        HUD.show(.progress)
        chaptersArray.removeAll()
        APIRequestUtil.AlQuranChapters(completion: callChaptersAPICompleted)
    }
    
    fileprivate func callChaptersAPICompleted(response: Any?, error: Error?) {
        HUD.hide()
        
        if let response = response {
            let json = JSON(response)
            let chapters = json["chapters"]
            for chapter in chapters.arrayValue {
                chaptersArray.append(ChapterModel.init(fromJson: chapter))
            }
            tableView.reloadData()
            
        } else {
            showEmptyVu()
        }
    }
}

extension ChaptersListingVC {
    func callJuzAPI(){
        HUD.show(.progress)
        parahArray.removeAll()
        APIRequestUtil.AlQuranJuzs(completion: callJuzAPICompleted)
    }
    
    fileprivate func callJuzAPICompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response {
            let json = JSON(response)
            let juzs = json["juzs"]
            var seenJuzNumbers = Set<Int>()
            for juz in juzs.arrayValue {
                let juzItem = Juzs.init(fromJson: juz)
                // Filter out duplicate juz entries based on juzNumber
                if !seenJuzNumbers.contains(juzItem.juzNumber) && juzItem.juzNumber > 0 {
                    seenJuzNumbers.insert(juzItem.juzNumber)
                    parahArray.append(juzItem)
                }
            }
            // Sort by juz number to ensure correct order
            parahArray.sort { $0.juzNumber < $1.juzNumber }
            tableView.reloadData()
        } else {
            showEmptyVu()
        }
    }
}
