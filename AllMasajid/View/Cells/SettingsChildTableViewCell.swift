//
//  SettingsChildTableViewCell.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 4/6/19.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import UIKit
import DropDown



class SettingsChildTableViewCell: UITableViewCell {

    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var delegate : SettingsTableViewDelegate?
    let dropdown = DropDown()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configDropDown(items : [String] ,sectionIndex:Int, rowIndex : Int,selectedIndex : Int){
        dropdown.anchorView = self
        dropdown.dataSource = items
        dropdown.cellHeight = 30
        dropdown.selectRow(selectedIndex)
        dropdown.textColor = UIColor.white
        //  dropdown.textFont = UIFont.boldSystemFont(ofSize: 12)
        dropdown.textFont = UIFont(name: "PTSans-Bold", size: 12)!
        dropdown.backgroundColor = UIColor(red:0.04, green:0.20, blue:0.38, alpha:1.0)
        dropdown.selectionBackgroundColor = UIColor(red:0.06, green:0.45, blue:0.83, alpha:1.0)
        dropdown.width = 0.9 * UIScreen.main.bounds.width
        let x = 0.05 * UIScreen.main.bounds.width
        dropdown.bottomOffset = CGPoint(x: x, y:(dropdown.anchorView?.plainView.bounds.height)!)
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            self.delegate?.didSelectDropDownItem(sectionIndex: sectionIndex, rowIndex: rowIndex, index: index)
            
            
        }
    }

}
