//
//  ThreeDotVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 13/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class ThreeDotVC: UIViewController {
    
    var delegate : ThreeDotProtocol?

    var screen = ""
    var activeItem = [ThreeDotModel.ThreeDot]()
    
    @IBOutlet weak var blackView: UIView!
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupInitials()
    }
    
    @IBAction func threeDotPressed(_ sender: UIButton) {
        activeItem.removeAll()
        self.dismiss(animated: false, completion: nil)
    }
    
    func setupInitials(){
        
        if screen == "item1" {
            activeItem = ThreeDotModel.item1
        }else if screen == "item2" {
            activeItem = ThreeDotModel.item2
        }else if screen == "item3" {
            activeItem = ThreeDotModel.item3
        }else if screen == "item4" {
            activeItem = ThreeDotModel.item4
        }else if screen == "item5"{
            activeItem = ThreeDotModel.item5
        }else if screen == "item6"{
            activeItem = ThreeDotModel.item6
        }else if screen == "item7"{
            activeItem = ThreeDotModel.item7
        }else if screen == "item8"{
            activeItem = ThreeDotModel.item8
        }

        myTableView.register(UINib(nibName: "ThreeDotTVC", bundle: nil), forCellReuseIdentifier: "ThreeDotTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
                blackView.addGestureRecognizer(gestureRecognizer)
        let gestureRecognizer2 = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
                myTableView.addGestureRecognizer(gestureRecognizer2)
    }
    
    @objc func backgroundTap(gesture : UITapGestureRecognizer) {
        activeItem.removeAll()
        self.dismiss(animated: false, completion: nil)
        view.endEditing(true)
    }
}

extension ThreeDotVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "ThreeDotTVC", for: indexPath) as! ThreeDotTVC
        cell.titleLBL.text = activeItem[indexPath.row].title
        cell.myBtn.setImage(activeItem[indexPath.row].icon, for: .normal)
        cell.myBtn.tag = indexPath.row
        cell.myBtn.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
        return cell
    }
    
    @objc func btnPressed(sender: UIButton){
        
        let row = sender.tag
        
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false) {
                
                guard let action = self.delegate else {return}

                if self.activeItem[row].title == "Add" {
                    action.addBtnPressed()
                }else if self.activeItem[row].title == "Refresh" {
                    action.refreshBtnPressed()
                }else if self.activeItem[row].title == "FAQ" {
                    action.faqBtnPressed()
                }else if self.activeItem[row].title == "Feedback" {
                    action.feedbackBtnPressed()
                }else if self.activeItem[row].title == "Help" {
                    action.helpBtnPressed()
                }else if self.activeItem[row].title == "Share" {
                    action.shareBtnPressed()
                }else if self.activeItem[row].title == "Favourites" {
                    action.favouritesBtnPressed()
                }else if self.activeItem[row].title == "About Us"{
                    action.aboutUsBtnPressed()
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
