//
//  DegreeAlertViewController.swift
//  AllMasajid
//
//  Created by Shahriyar Memon on 5/4/19.
//  Copyright © 2019 Shahriyar Memon. All rights reserved.
//

import UIKit
import DropDown

class DegreeAlertViewController: UIViewController {

    @IBOutlet weak var btnIsha: UIButton!
    @IBOutlet weak var btnFajr: UIButton!
    
    @IBOutlet weak var btnFajrDrop: UIButton!
    @IBOutlet weak var btnIshaDrop: UIButton!
    
    var fajrStrings : [String] = ["12","15","18","18.5","19.5","20"]
    var ishaStrings : [String] = ["12","15","17","17.5","18","20"]
    var dropdownFajr = DropDown()
    var dropdownIsha = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDropdowns()
    }
    
    func setupDropdowns(){
        
        dropdownFajr.anchorView = btnFajr
        dropdownFajr.anchorView = btnFajrDrop //NEWADDED
        dropdownFajr.dataSource = fajrStrings
        dropdownFajr.cellHeight = 30
        
        if let selectedItem = defaults.string(forKey: "FajrAngle"),selectedItem != ""{
            
            dropdownFajr.selectRow(fajrStrings.lastIndex(of: selectedItem)!)
            btnFajr.setTitle(selectedItem, for: .normal)
            
        }
        
       // dropdownFajr.selectRow(selectedIndex)
        dropdownFajr.textColor = UIColor.white
        //  dropdown.textFont = UIFont.boldSystemFont(ofSize: 12)
        dropdownFajr.textFont = UIFont(name: "PTSans-Bold", size: 12)!
        dropdownFajr.backgroundColor = UIColor(red:0.04, green:0.20, blue:0.38, alpha:1.0)
        dropdownFajr.selectionBackgroundColor = UIColor(red:0.06, green:0.45, blue:0.83, alpha:1.0)
        dropdownFajr.width = btnFajr.frame.size.width
        let x = 0.05 * UIScreen.main.bounds.width
        dropdownFajr.bottomOffset = CGPoint(x: x, y:(dropdownFajr.anchorView?.plainView.bounds.height)!)
        dropdownFajr.selectionAction = { [unowned self] (index: Int, item: String) in
            
         self.btnFajr.setTitle(item, for: .normal)
            defaults.set(item, forKey: "FajrAngle")
            
        }
        
        dropdownIsha.anchorView = btnIsha
        dropdownIsha.anchorView = btnIshaDrop
        
        dropdownIsha.dataSource = ishaStrings
        dropdownIsha.cellHeight = 30
        if let selectedItem = defaults.string(forKey: "IshaAngle"),selectedItem != ""{
            dropdownIsha.selectRow(ishaStrings.lastIndex(of: selectedItem)!)
            btnIsha.setTitle(selectedItem, for: .normal)
        }
        // dropdownFajr.selectRow(selectedIndex)
        dropdownIsha.textColor = UIColor.white
        //  dropdown.textFont = UIFont.boldSystemFont(ofSize: 12)
        dropdownIsha.textFont = UIFont(name: "PTSans-Bold", size: 12)!
        dropdownIsha.backgroundColor = UIColor(red:0.04, green:0.20, blue:0.38, alpha:1.0)
        dropdownIsha.selectionBackgroundColor = UIColor(red:0.06, green:0.45, blue:0.83, alpha:1.0)
        dropdownIsha.width = btnFajr.frame.size.width
      
        dropdownIsha.bottomOffset = CGPoint(x: x, y:(dropdownIsha.anchorView?.plainView.bounds.height)!)
        dropdownIsha.selectionAction = { [unowned self] (index: Int, item: String) in
            
            defaults.set(item, forKey: "IshaAngle")
            self.btnIsha.setTitle(item, for: .normal)
            
        }
    }
    
    @IBAction func confirmSetting(_ sender: Any) {
        if (defaults.string(forKey: "FajrAngle") != "") && (defaults.string(forKey: "IshaAngle") != "") {
            defaults.set(1, forKey: "Prayers Calculation Method")
              NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "ReloadTable")))
             self.dismiss(animated: true, completion: nil)
        }
        else{
            Alert.showMsg(msg: "Please choose both angles first")
        }
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleFajrDropdown(_ sender: Any) {
        if dropdownFajr.isHidden {
            dropdownFajr.show()
        }
        else{
            dropdownFajr.hide()
        }
    }
    
    @IBAction func toggleIshaDropdown(_ sender: Any) {
        if dropdownIsha.isHidden {
            dropdownIsha.show()
        }
        else{
            dropdownIsha.hide()
        }
    }
    
}
