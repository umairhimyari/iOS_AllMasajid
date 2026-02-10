//
//  ChapterDetailVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import SwiftyJSON

enum VerseType: String {
    case chapter = "chapter_number"
    case juz = "juz_number"
}

class ChapterDetailVC: BaseVC {
    
    var id = 0
    var type: VerseType = .chapter
    var verses = [Verse]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
        callVersesAPI()
    }
}

extension ChapterDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerseTVC", for: indexPath) as! VerseTVC
        cell.setContent(item: verses[indexPath.row])
        return cell
    }
}

extension ChapterDetailVC: TryAgainProtocol {
    
    func setupInitials() {
        tableView.register(UINib(nibName: "VerseTVC", bundle: nil), forCellReuseIdentifier: "VerseTVC")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    func tryAgain() {
        callVersesAPI()
    }
    
    func showEmptyVu() {
        let vc = UIStoryboard().LoadTryAgainScreen()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.parent?.present(vc, animated: false, completion: nil)
    }
}


extension ChapterDetailVC {
    func callVersesAPI() {
        HUD.show(.progress)
        verses.removeAll()
        APIRequestUtil.AlQuranVerses(params: "?\(type.rawValue)=\(id)", completion: callVersesAPCompleted)
    }
    
    fileprivate func callVersesAPCompleted(response: Any?, error: Error?) {
        HUD.hide()
        
        if let response = response {
            let json = JSON(response)
            let verses = json["verses"]
            for i in verses.arrayValue {
                self.verses.append(Verse.init(fromJson: i))
            }
            tableView.reloadData()
            
        } else {
            showEmptyVu()
        }
    }
}
