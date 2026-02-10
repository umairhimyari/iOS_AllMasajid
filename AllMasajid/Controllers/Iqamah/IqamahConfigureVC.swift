//
//  IqamahConfigureVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 20/10/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit
//import Adhan
import PKHUD
import SwiftyJSON
import SafariServices

class IqamahConfigureVC: UIViewController {
    
    var fajrCurr: Date?
    var duhrCurr: Date?
    var asrCurr: Date?
    var maghribCurr: Date?
    var ishaCurr: Date?
    var sunriseCurr: Date?
    var chashtCurr: Date?
    var awabeenCurr: Date?
    var ishraqCurr: Date?
    var tahajjudCurr: Date?
    
    var masjidIDReceived = ""
    var masjidName = ""
    var address = ""
    
    var prayers = ["Fajr", "Dhuhr", "Asr", "Magrib", "Isha'a", "Jummah"]
    var addedPrayers = [0, 0, 0, 0, 0, 0, 0]
    
    var entriesArray = [IqamahEntries]()
    var fajrPrayerArray = [String]()
    var duhrrPrayerArray = [String]()
    var asrPrayerArray = [String]()
    var ishaPrayerArray = [String]()
    var jummahPrayerArray = [String]()
    var maghribPrayerTime: String = ""
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    
    var maghribArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    let maghribPicker = UIPickerView()
    var datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    var tempCellIndex = -1
    
    @IBOutlet weak var mosqueNameLBL: UILabel!
    @IBOutlet weak var addressLBL: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mosqueNameLBL.text = masjidName
        addressLBL.text = address
        
        getNamazTimings()
        setupInitials()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "h:mm"
        
        maghribPicker.delegate = self
        
        if #available(iOS 14.0, *){
            datePicker.preferredDatePickerStyle = .wheels
            timePicker.preferredDatePickerStyle = .wheels
        }
        
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
                blackView.addGestureRecognizer(gestureRecognizer)
        
        showDatePicker()
    }
    
    @IBAction func threeDotBtnPressed(_ sender: UIButton) {
        
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item3"
        self.parent?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func backgroundTap(gesture : UITapGestureRecognizer) {
        blackView.isHidden = true
        myTableView.reloadData()
        view.endEditing(true)
    }
}

extension IqamahConfigureVC: ThreeDotProtocol {
    func addBtnPressed() {
        print("Do Nothing")
    }
    
    func faqBtnPressed() {
        let vc = UIStoryboard().LoadFaqScreen()
        vc.screen = "iqamah"
        vc.titleStr = "Iqamah"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshBtnPressed() {
        print("Do Nothing")
    }
    
    func shareBtnPressed() {
        print("Do Nothing")
    }
    
    func helpBtnPressed() {
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}

extension IqamahConfigureVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7//6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedPrayers[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var cell: UITableViewCell?
        
        if section == 6 {
            
            let headercell = Bundle.main.loadNibNamed("IqamahConfigureBottomTVC", owner: self, options: nil)?.first as! IqamahConfigureBottomTVC
            headercell.submitBtn.addTarget(self, action: #selector(submitBtnPressed), for: .touchUpInside)
            cell = headercell
        }else if section == 5 { // Jummah
            
            let headercell = Bundle.main.loadNibNamed("IqamahMaghribTVC", owner: self, options: nil)?.first as! IqamahMaghribTVC
            headercell.namazTitle.text = "\(prayers[section]) 1"
            headercell.addBtn.setImage(#imageLiteral(resourceName: "nawafils"), for: .normal)
            headercell.addBtn.addTarget(self, action: #selector(addPrayerTime), for: .touchUpInside)
            headercell.addBtn.tag = section
            
            headercell.minuteTF.placeholder = "Enter Jummah Time"
            
            for i in 0..<entriesArray.count{
                if entriesArray[i].isSection == true && entriesArray[i].sectionIndex == section {
                    
                    if entriesArray[i].time != ""  {
                        headercell.addBtn.setImage(#imageLiteral(resourceName: "plus-icon"), for: .normal)
                        headercell.addBtn.isEnabled = true
                    } else {
                        headercell.addBtn.isEnabled = false
                    }
                    
                    headercell.minuteTF.text = entriesArray[i].time
                    break
                }
            }
            
            headercell.minuteTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            headercell.minuteTF.tag = 61
            
            cell = headercell
        }else if section == 3 {
            
            let headercell = Bundle.main.loadNibNamed("IqamahMaghribTVC", owner: self, options: nil)?.first as! IqamahMaghribTVC
            headercell.namazTitle.text = prayers[section]
            headercell.addBtn.setImage(#imageLiteral(resourceName: "MAGHRIB-icon"), for: .normal)
            
            for i in 0..<entriesArray.count{
                if entriesArray[i].isSection == true && entriesArray[i].sectionIndex == section {
                    headercell.minuteTF.text = entriesArray[i].time
                    break
                }
            }
            
            headercell.minuteTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            headercell.minuteTF.tag = 54
            cell = headercell
            
        }else{
            let headercell = Bundle.main.loadNibNamed("IqamahConfigureTVC", owner: self, options: nil)?.first as! IqamahConfigureTVC
            
            headercell.namazTitleLBL.text = prayers[section]
            headercell.addBtn.addTarget(self, action: #selector(addPrayerTime), for: .touchUpInside)
            headercell.addBtn.tag = section
            
            if section == 0 {
                headercell.addBtn.setImage(#imageLiteral(resourceName: "fajr-iconIqamah"), for: .normal)
            }else if section == 1 {
                headercell.addBtn.setImage(#imageLiteral(resourceName: "dhuhr-iconIqamah"), for: .normal)
            }else if section == 2 {
                headercell.addBtn.setImage(#imageLiteral(resourceName: "ASR-icon"), for: .normal)
            }else if section == 4 {
                headercell.addBtn.setImage(#imageLiteral(resourceName: "ISHA-icon"), for: .normal)
            }
            
            for i in 0..<entriesArray.count{
                if entriesArray[i].isSection == true && entriesArray[i].sectionIndex == section {
                    
                    if entriesArray[i].endDate != "" && entriesArray[i].startDate != "" && entriesArray[i].time != ""  {
                        headercell.addBtn.setImage(#imageLiteral(resourceName: "plus-icon"), for: .normal)
                        headercell.addBtn.isEnabled = true
                    }else{
                        headercell.addBtn.isEnabled = false
                    }
                    
                    headercell.startDateTF.text = entriesArray[i].startDate
                    headercell.endDateTF.text = entriesArray[i].endDate
                    headercell.timeTF.text = entriesArray[i].time
                    break
                }
            }
            
            headercell.startDateTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            headercell.endDateTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            headercell.timeTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            
            if section == 0 {
                headercell.timeTF.tag = 51 // Fajr
                headercell.startDateTF.tag = 33
                headercell.endDateTF.tag = 43
            }else if section == 1 {
                headercell.timeTF.tag = 52 //Duhr
                headercell.startDateTF.tag = 34
                headercell.endDateTF.tag = 44
            }else if section == 2 {
                headercell.timeTF.tag = 53 //Asr
                headercell.startDateTF.tag = 35
                headercell.endDateTF.tag = 45
            }else if section == 4 {
                headercell.timeTF.tag = 55 //Isha
                headercell.startDateTF.tag = 37
                headercell.endDateTF.tag = 47
            }
            
            cell = headercell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        if indexPath.section == 5 {
            
            let jummahCell = myTableView.dequeueReusableCell(withIdentifier: "IqamahMaghribTVC", for: indexPath) as! IqamahMaghribTVC
            
            jummahCell.namazTitle.text = "\(prayers[indexPath.section]) \(indexPath.row + 2)"
            jummahCell.backView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
            jummahCell.addBtn.isHidden = true
            
            jummahCell.minuteTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            jummahCell.minuteTF.tag = Int("4\(indexPath.section)\(indexPath.row)") ?? 0
            jummahCell.minuteTF.text = ""
            
            jummahCell.minuteTF.placeholder = "Enter Jummah Time"
            
            for i in 0..<entriesArray.count{
                if entriesArray[i].isSection == false && entriesArray[i].sectionIndex == indexPath.section && entriesArray[i].cellIndex == indexPath.row {
                    
                    jummahCell.minuteTF.text = entriesArray[i].time
                    break
                }
            }
            
            cell = jummahCell
            
        }else{
            
            let myCell = myTableView.dequeueReusableCell(withIdentifier: "IqamahConfigureTVC", for: indexPath) as! IqamahConfigureTVC
            
            myCell.namazTitleLBL.text = prayers[indexPath.section]
            myCell.backView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
            myCell.addBtn.isHidden = true
            myCell.startDateTF.text = ""
            myCell.endDateTF.text = ""
            myCell.timeTF.text = ""
            
            for i in 0..<entriesArray.count{
                if entriesArray[i].isSection == false && entriesArray[i].sectionIndex == indexPath.section && entriesArray[i].cellIndex == indexPath.row {
                    
                    myCell.startDateTF.text = entriesArray[i].startDate
                    myCell.endDateTF.text = entriesArray[i].endDate
                    myCell.timeTF.text = entriesArray[i].time
                    break
                }
            }
            
            myCell.startDateTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            myCell.endDateTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            myCell.timeTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidBegin)
            
            myCell.timeTF.tag = Int("1\(indexPath.section)\(indexPath.row)") ?? 0
            myCell.startDateTF.tag = Int("2\(indexPath.section)\(indexPath.row)") ?? 0
            myCell.endDateTF.tag = Int("3\(indexPath.section)\(indexPath.row)") ?? 0
            
            cell = myCell
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var cellHeight = 0
        
        if section == 6 {
            cellHeight = 120
        }else{
            cellHeight = 50
        }
        
        return CGFloat(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @objc func addPrayerTime(sender: UIButton){
        
        if addedPrayers[sender.tag] < 5 {
            let temp = addedPrayers[sender.tag] + 1
            addedPrayers.remove(at: sender.tag)
            addedPrayers.insert(temp, at: sender.tag)
        }
        myTableView.reloadData()
    }
    
    @objc func submitBtnPressed(sender: UIButton){
        
        fajrPrayerArray.removeAll()
        duhrrPrayerArray.removeAll()
        asrPrayerArray.removeAll()
        ishaPrayerArray.removeAll()
        jummahPrayerArray.removeAll()
        
        for index in 0..<entriesArray.count {
            
            if entriesArray[index].time != "" {
                
                if entriesArray[index].sectionIndex == 3 {
                    
                    maghribPrayerTime = entriesArray[index].time ?? ""
                    
                }else if entriesArray[index].sectionIndex == 5 {
                    
                    var jummahType = ""
                    
                    if entriesArray[index].isSection == true {
                        jummahType = "jumah-1"
                    }else if entriesArray[index].cellIndex == 0 {
                        jummahType = "jumah-2"
                    }else if entriesArray[index].cellIndex == 1 {
                        jummahType = "jumah-3"
                    }else if entriesArray[index].cellIndex == 2 {
                        jummahType = "jumah-4"
                    }else if entriesArray[index].cellIndex == 3 {
                        jummahType = "jumah-5"
                    }else if entriesArray[index].cellIndex == 4 {
                        jummahType = "jumah-6"
                    }                    
                    
                    let ab = JSON(["time": "\(entriesArray[index].time ?? "")", "type": "\(jummahType)"])
                    
                    let paraString = ab.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions())!
                    jummahPrayerArray.append(paraString)
                    
                }else if entriesArray[index].startDate != "" {
                    
                    var endDate = ""
                    if entriesArray[index].endDate == "" {
                        endDate = "\(entriesArray[index].startDate ?? "")"
                    }else {
                        endDate = "\(entriesArray[index].endDate ?? "")"
                    }

                    let ab = JSON(["time": "\(entriesArray[index].time ?? "")","toDate": "\(entriesArray[index].startDate ?? "")","endDate": endDate])
                    let paraString = ab.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions())!
                    
                    if entriesArray[index].sectionIndex == 0 {
                        fajrPrayerArray.append(paraString)
                        
                    }else if entriesArray[index].sectionIndex == 1 {
                        duhrrPrayerArray.append(paraString)
                        
                    }else if entriesArray[index].sectionIndex == 2 {
                        
                        asrPrayerArray.append(paraString)
                        
                    }else if entriesArray[index].sectionIndex == 4 {
                        
                        ishaPrayerArray.append(paraString)
                        
                    }
                }
            }
        }
        
        networkHit()
    }
}

extension IqamahConfigureVC{
    
    func setupInitials(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.footerViewTapped(_:)))
        footerView.addGestureRecognizer(tap)
        myTableView.register(UINib(nibName: "IqamahConfigureTVC", bundle: nil), forCellReuseIdentifier: "IqamahConfigureTVC")
        myTableView.register(UINib(nibName: "IqamahMaghribTVC", bundle: nil), forCellReuseIdentifier: "IqamahMaghribTVC")
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
    }
    
    @objc func footerViewTapped(_ sender: UITapGestureRecognizer? = nil) {
    
          let url = URL(string: allMWebURL)
          let vc = SFSafariViewController(url: url!)
          present(vc, animated: true, completion: nil)
      }
}

extension IqamahConfigureVC {
    
    //--------------------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------------- CELL
    //--------------------------------------------------------------------------------------------------
    
    func showDatePicker(){

        timePicker.datePickerMode = .time

        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()

        // Note: IQKeyboardManager toolbar configuration for UIDatePicker is not supported in newer versions
        // datePicker.iq.toolbar.nextBarButton.accessibilityElementsHidden = true
        // datePicker.iq.toolbar.previousBarButton.accessibilityElementsHidden = true

    }

    @objc func doneFajrStartDatePicker(){
        setupStartDate(isSection: false, section: 0, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneFajrEndDatePicker(){
        setupEndDate(isSection: false, section: 0, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneDuhrStartDatePicker(){
        setupStartDate(isSection: false, section: 1, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneDuhrEndDatePicker(){
        setupEndDate(isSection: false, section: 1, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneAsrStartDatePicker(){
        setupStartDate(isSection: false, section: 2, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneAsrEndDatePicker(){
        setupEndDate(isSection: false, section: 2, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneIshaStartDatePicker(){
        setupStartDate(isSection: false, section: 4, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneIshaEndDatePicker(){
        setupEndDate(isSection: false, section: 4, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    

    
    //--------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------ SECTION
    //--------------------------------------------------------------------------------------------------
    
    @objc func doneFajrSectionStartDatePicker(){
        setupStartDate(isSection: true, section: 0, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneFajrSectionEndDatePicker(){
        setupEndDate(isSection: true, section: 0, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneDuhrSectionStartDatePicker(){
        setupStartDate(isSection: true, section: 1, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneDuhrSectionEndDatePicker(){
        setupEndDate(isSection: true, section: 1, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneAsrSectionStartDatePicker(){
        setupStartDate(isSection: true, section: 2, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneAsrSectionEndDatePicker(){
        setupEndDate(isSection: true, section: 2, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneIshaSectionStartDatePicker(){
        setupStartDate(isSection: true, section: 4, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneIshaSectionEndDatePicker(){
        setupEndDate(isSection: true, section: 4, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneMaghribSectionPicker(){
        setupMaghribTime(isSection: true, section: 3, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
        myTableView.reloadData()
        blackView.isHidden = true
        self.view.endEditing(true)
    }
}


extension IqamahConfigureVC{
    
    //--------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------ SECTION
    //--------------------------------------------------------------------------------------------------

    @objc func doneFajrSectionTimePicker(){
        setupTime(isSection: true, section: 0, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneDuhrSectionTimePicker(){
        setupTime(isSection: true, section: 1, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneAsrSectionTimePicker(){
        setupTime(isSection: true, section: 2, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneIshaSectionTimePicker(){
        setupTime(isSection: true, section: 4, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneJummahSectionTimePicker(){
        setupTime(isSection: true, section: 5, cell: -1)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    //--------------------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------------- CELL
    //--------------------------------------------------------------------------------------------------
    
    @objc func doneFajrTimePicker(){
        setupTime(isSection: false, section: 0, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneDuhrTimePicker(){
        setupTime(isSection: false, section: 1, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneAsrTimePicker(){
        setupTime(isSection: false, section: 2, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneIshaTimePicker(){
        setupTime(isSection: false, section: 4, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func doneJummahTimePicker(){
        setupTime(isSection: false, section: 5, cell: tempCellIndex)
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
}

extension IqamahConfigureVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        blackView.isHidden = true
        myTableView.reloadData()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        myTableView.reloadData()
        blackView.isHidden = true
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(textfield: UITextField) {
        
        var doneButton: UIBarButtonItem!
        blackView.isHidden = false
        
        //--------------------------------------------------------------------------------------------------
        //------------------------------------------------------------------------------------------ SECTION
        //--------------------------------------------------------------------------------------------------
        
        if textfield.tag >= 33 && textfield.tag <= 47 {
            
            if textfield.tag == 33 { //Fajr Section
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneFajrSectionStartDatePicker))
                
            }else if textfield.tag == 34 { //Duhr Section
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneDuhrSectionStartDatePicker))
            }else if textfield.tag == 35 { //Asr Section
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAsrSectionStartDatePicker))
            }else if textfield.tag == 37 { //Isha Section
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneIshaSectionStartDatePicker))
            }
            
            else if textfield.tag == 43 { //Fajr Section
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneFajrSectionEndDatePicker))
                
            }else if textfield.tag == 44 { //Duhr Section
                
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneDuhrSectionEndDatePicker))
                
            }else if textfield.tag == 45 { //Asr Section
                
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAsrSectionEndDatePicker))
                
            }else if textfield.tag == 47 { //Isha Section
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneIshaSectionEndDatePicker))
            }
            textfield.inputView = datePicker
            
        }else if textfield.tag == 54 { //Section Maghrib
            
            doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneMaghribSectionPicker))
            textfield.inputView = maghribPicker
            
        }else if textfield.tag >= 51 && textfield.tag < 54 || textfield.tag == 55 || textfield.tag == 61{

            if textfield.tag == 51 { //Section Fajr
//                timePicker.minimumDate = fajrCurr // January 11
//                timePicker.maximumDate = sunriseCurr // January 11
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneFajrSectionTimePicker))
                                
            }else if textfield.tag == 52 { //Section Duhr
//                timePicker.minimumDate = duhrCurr // January 11
//                timePicker.maximumDate = asrCurr // January 11
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneDuhrSectionTimePicker))
                                
            }else if textfield.tag == 53 { //Section Asr
//                timePicker.minimumDate = asrCurr // January 11
//                timePicker.maximumDate = maghribCurr // January 11
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAsrSectionTimePicker))
                                
            }else if textfield.tag == 55 { //Section Isha
//                timePicker.minimumDate = ishaCurr // January 11
//                timePicker.maximumDate = fajrCurr // January 11
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneIshaSectionTimePicker))
                
            }else if textfield.tag == 61 { //Section Jumah
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneJummahSectionTimePicker))
            }
            
            textfield.inputView = timePicker
        }
        
        //--------------------------------------------------------------------------------------------------
        //--------------------------------------------------------------------------------------------- CELL
        //--------------------------------------------------------------------------------------------------
        
        else if textfield.tag >= 100 && textfield.tag <= 124 || textfield.tag >= 140 && textfield.tag <= 144 || textfield.tag >= 450 && textfield.tag <= 454{
             // Time
            let myTag = "\(textfield.tag)"
            let myStr = "\(myTag.getCharAtIndex(2))"
            tempCellIndex = Int(myStr) ?? -1
            
            if textfield.tag >= 100 && textfield.tag <= 104{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneFajrTimePicker))
                
            }else if textfield.tag >= 110 && textfield.tag <= 114{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneDuhrTimePicker))
                
            }else if textfield.tag >= 120 && textfield.tag <= 124{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAsrTimePicker))
                
            }else if textfield.tag >= 140 && textfield.tag <= 144{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneIshaTimePicker))
            }else if textfield.tag >= 450 && textfield.tag <= 454{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneJummahTimePicker))
            }
            
            textfield.inputView = timePicker
            
        }else if textfield.tag >= 200 && textfield.tag <= 344 {
            // Date
            let myTag = "\(textfield.tag)"
            let myStr = "\(myTag.getCharAtIndex(2))"
            tempCellIndex = Int(myStr) ?? -1
            
            if textfield.tag >= 200 && textfield.tag <= 204{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneFajrStartDatePicker))
                
            }else if textfield.tag >= 300 && textfield.tag <= 304{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneFajrEndDatePicker))
                
            }
                
            else
            
            if textfield.tag >= 210 && textfield.tag <= 214{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneDuhrStartDatePicker))
                
            }else if textfield.tag >= 310 && textfield.tag <= 314{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneDuhrEndDatePicker))
                
            }
                
            else
                
            if textfield.tag >= 220 && textfield.tag <= 224{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAsrStartDatePicker))
                
            }else if textfield.tag >= 320 && textfield.tag <= 324{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAsrEndDatePicker))
            }
            
            else
            
            if textfield.tag >= 240 && textfield.tag <= 244{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneIshaStartDatePicker))
                
            }else if textfield.tag >= 340 && textfield.tag <= 344{
                doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneIshaEndDatePicker))
                
            }
            
            textfield.inputView = datePicker
            
        }
        
        let toolBar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        toolBar.tintColor = .black
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([doneButton], animated: false)
        textfield.inputAccessoryView = toolBar
    }
}

extension IqamahConfigureVC {

    func getNamazTimings(){
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        
        var myLong: Double = 0
        if let long = UserDefaults.standard.object(forKey: "longGPS") as? String {
            myLong = Double("\(long)") ?? 0
        }
        
        var myLat: Double = 0
        if let lat = UserDefaults.standard.object(forKey: "latGPS") as? String {
            myLat = Double("\(lat)") ?? 0
        }
        
        let coordinates = Coordinates(latitude: myLat, longitude: myLong)
        
        var params = calculationMethods[UserDefaults.standard.integer(forKey: "Method")].params
        
        if UserDefaults.standard.integer(forKey: "Prayers Calculation Method") == 1 {
            
            params = CalculationParameters(fajrAngle: Double(UserDefaults.standard.string(forKey: "FajrAngle")!)!, ishaAngle: Double(UserDefaults.standard.string(forKey: "IshaAngle")!)!)
        }
        
        params.madhab = madhabs[UserDefaults.standard.integer(forKey: "School/Juristic")]
        
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            
            fajrCurr = prayers.fajr
            sunriseCurr = prayers.sunrise
            ishraqCurr = prayers.time(for: Prayer.ishraaq)
            chashtCurr = prayers.time(for: Prayer.chaasht)
            duhrCurr = prayers.dhuhr.addingTimeInterval(TimeInterval(6*60))
            asrCurr = prayers.asr
            maghribCurr = prayers.maghrib
            awabeenCurr = prayers.time(for: Prayer.awabeen)
            tahajjudCurr = prayers.time(for: Prayer.tahajjud)
            ishaCurr = prayers.isha
        }
    }
}

extension IqamahConfigureVC {
    
    func setupStartDate(isSection: Bool, section: Int, cell: Int) {
        let startDate = dateFormatter.string(from: datePicker.date)
        var changed = false
        
        for i in 0..<entriesArray.count{
            if entriesArray[i].isSection == isSection && entriesArray[i].sectionIndex == section && entriesArray[i].cellIndex == cell {
                entriesArray[i].startDate = startDate
                changed = true
                break
            }
        }
        
        if changed == false {
            entriesArray.append(IqamahEntries(isSection: isSection, sectionIndex: section, cellIndex: cell, time: "", startDate: startDate, endDate: ""))
        }
        
        myTableView.reloadData()
    }
    
    func setupEndDate(isSection: Bool, section: Int, cell: Int){
        let endDate = dateFormatter.string(from: datePicker.date)
        var changed = false
        
        for i in 0..<entriesArray.count{
            if entriesArray[i].isSection == isSection && entriesArray[i].sectionIndex == section && entriesArray[i].cellIndex == cell{
                entriesArray[i].endDate = endDate
                changed = true
                break
            }
        }
        
        if changed == false {
            entriesArray.append(IqamahEntries(isSection: isSection, sectionIndex: section, cellIndex: cell, time: "", startDate: "", endDate: endDate))
        }
        
        myTableView.reloadData()
    }
    
}

extension IqamahConfigureVC {
    
    func setupTime(isSection: Bool, section: Int, cell: Int){
        let time = timeFormatter.string(from: timePicker.date)
        var changed = false
        
        for i in 0..<entriesArray.count{
            if entriesArray[i].isSection == isSection && entriesArray[i].sectionIndex == section && entriesArray[i].cellIndex == cell{
                entriesArray[i].time = time
                changed = true
                break
            }
        }
        
        if changed == false {
            entriesArray.append(IqamahEntries(isSection: isSection, sectionIndex: section, cellIndex: cell, time: time, startDate: "", endDate: ""))
        }
        
        myTableView.reloadData()
    }
    
    func setupMaghribTime(isSection: Bool, section: Int, cell: Int){
        let row = self.maghribPicker.selectedRow(inComponent: 0)
        self.maghribPicker.selectRow(0, inComponent: 0, animated: false)
        
        let time = maghribArray[row]
        var changed = false
        
        for i in 0..<entriesArray.count{
            if entriesArray[i].isSection == isSection && entriesArray[i].sectionIndex == section && entriesArray[i].cellIndex == cell{
                entriesArray[i].time = time
                changed = true
                break
            }
        }
        
        if changed == false {
            entriesArray.append(IqamahEntries(isSection: isSection, sectionIndex: section, cellIndex: cell, time: time, startDate: "", endDate: ""))
        }
        
        myTableView.reloadData()
    }
}


extension IqamahConfigureVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var value = 0
        if pickerView == maghribPicker{
            value = maghribArray.count
        }
        return value
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var value = ""
        if pickerView == maghribPicker{
            value = maghribArray[row]
        }
        return value
    }
}


extension IqamahConfigureVC{
    
    func networkHit(){
        HUD.show(.progress)
        
        var fajrStr: String = ""
        var duhrStr: String = ""
        var asrStr: String = ""
        var ishaStr: String = ""
        var jummahStr: String = ""
        
        if fajrPrayerArray.count > 0 {
            fajrStr = encodeStr(array: fajrPrayerArray)
        }
        
        if duhrrPrayerArray.count > 0 {
            duhrStr = encodeStr(array: duhrrPrayerArray)
        }
        
        if asrPrayerArray.count > 0 {
            asrStr = encodeStr(array: asrPrayerArray)
        }
        
        if ishaPrayerArray.count > 0 {
            ishaStr = encodeStr(array: ishaPrayerArray)
        }
        
        if jummahPrayerArray.count > 0 {
            jummahStr = encodeStr(array: jummahPrayerArray)
        }
                
        let params = [
            "fajr": fajrStr,
            "duhr": duhrStr,
            "asr": asrStr,
            "maghrib": maghribPrayerTime,
            "isha": ishaStr,
            "jumah": jummahStr
        ]
        
        APIRequestUtil.SendIqamahData(id: masjidIDReceived, parameters: params, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            self.navigationController?.popViewController(animated: true)
            
        }else{
            HUD.flash(.labeledError(title: "Connection Error", subtitle: "Please try again later"), delay: 0.6)
        }
    }
}

extension IqamahConfigureVC {
    
    func encodeStr(array: [String]) -> String{
        var jsonData: NSData!
        var myStr: String = ""
        do {
            jsonData = try JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions(rawValue: JSONSerialization.WritingOptions().rawValue)) as NSData
            myStr = String(data: jsonData as Data, encoding: String.Encoding.utf8) ?? ""
            return myStr
            
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
            return ""
        }
    }
}





//----- Section 0 - Fajr
//Time:              100, 101, 102, 103, 104
//Start Date:        200, 201, 202, 203, 204
//End Date           300, 301, 302, 303, 304

//----- Section 1 - Duhr
//Time:              110, 111, 112, 113, 114
//Start Date:        210, 211, 212, 213, 214
//End Date           310, 311, 312, 313, 314

//----- Section 2 - Asr
//Time:              120, 121, 122, 123, 124
//Start Date:        220, 221, 222, 223, 224
//End Date           320, 321, 322, 323, 324

//----- Section 3 - Maghrib
//Time:              130, 131, 132, 133, 134 //Removed

//----- Section 4 - Isha
//Time:              140, 141, 142, 143, 144
//Start Date:        240, 241, 242, 243, 244
//End Date           340, 341, 342, 343, 344
