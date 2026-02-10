//
//  SideMenuVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 19/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController {

    var menuProtocol: SideMenuProtocol?
    var items = [MenuItems]()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
}

extension SideMenuVC{
    func setupInitials(){
        populateItems()
        setupTableView()
        
        let gestureBlackView = UITapGestureRecognizer(target: self, action:  #selector(self.blackViewPressed))
        self.blackView.addGestureRecognizer(gestureBlackView)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(goBackGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func populateItems(){
        items.append(MenuItems(title: "Profile", image: #imageLiteral(resourceName: "View Profile")))
        items.append(MenuItems(title: "Feedback", image: #imageLiteral(resourceName: "Feedback")))
        items.append(MenuItems(title: "How To Use App", image: #imageLiteral(resourceName: "How2UseAppIcon")))
        items.append(MenuItems(title: "Logout", image: #imageLiteral(resourceName: "Logout")))
    }

    func setupTableView(){
        myTableView.register(UINib(nibName: "SideMenuTVC", bundle: nil), forCellReuseIdentifier: "SideMenuTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        myTableView.rowHeight = 60
    }
    
    @objc func blackViewPressed(sender : UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func goBackGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == .left {
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "SideMenuTVC", for: indexPath) as! SideMenuTVC
        cell.titleLBL.text = items[indexPath.row].title
        cell.myIMG.image = items[indexPath.row].image
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false) {
                guard let action = self.menuProtocol else {return}

                if indexPath.row == 0{
                    
                    action.profilePressed()
                    
                }else if indexPath.row == 1{
                   
                    action.feedbackPressed()
                    
                }else if indexPath.row == 2{
                    
                    action.how2UseAppPressed()
                    
                }else if indexPath.row == 3{
                    
                    action.logoutPressed()
                    
                }
            }
        })
    }
}
