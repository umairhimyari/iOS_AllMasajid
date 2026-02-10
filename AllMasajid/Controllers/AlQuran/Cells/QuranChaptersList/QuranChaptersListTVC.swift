//
//  QuranChaptersListTVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/03/2023.
//  Copyright © 2023 allMasajid. All rights reserved.
//

import UIKit

class QuranChaptersListTVC: UITableViewCell {

    @IBOutlet weak var countLBL: UILabel!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var verseCountLBL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setChapter(item: ChapterModel) {
        titleLBL.text = item.name
        verseCountLBL.text = "verses: \(item.versesCount)"
        countLBL.text = "\(item.id)"
    }
    
    func setJuz(item: Juzs) {
        titleLBL.text = "Parah \(item.juzNumber)"
        verseCountLBL.text = "verses: \(item.versesCount)"
        countLBL.text = "\(item.juzNumber)"
    }
}
