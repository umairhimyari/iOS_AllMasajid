//
//  MDBusinessVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import CoreLocation

struct MDBusiness {
    var name = ""
    var vicinity = ""
    var photo_reference = ""
    var place_id = ""
    var rating = 0.0
    var longs = 0.0
    var lats = 0.0
}

class MDBusinessVC: UIViewController {
    
    var firstTime = true
    var nextToken = ""
    var isRefreshing = false
    var currentCat = "Restaurants"
    var currentKeyword = "halal"
    
    var categories = ["Restaurants", "Markets", "Caterers", "Business", "Others"]
    var items = [MDBusiness]()
    
    var searchArray = [MDBusiness]()
    var searchController: UISearchController!
    var searching : Bool = false
    var tempText = ""
    
    var observation: NSKeyValueObservation?
    var myLocation = CLLocation()
    @objc var objectToObserve: LocationManager!

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MDBusinessVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  searching == true ? searchArray.count : items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "MDItemTVC", for: indexPath) as! MDItemTVC
        if searching == true {
            cell.titleLBL.text = searchArray[indexPath.row].name
            cell.addressLBL.text = searchArray[indexPath.row].vicinity
        }else{
            cell.titleLBL.text = items[indexPath.row].name
            cell.addressLBL.text = items[indexPath.row].vicinity
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard().LoadMuslimDirectoryPopupScreen()
        vc.data = searching == true ? searchArray[indexPath.row] : items[indexPath.row]
        vc.currentLat = myLocation.coordinate.latitude
        vc.currentLong = myLocation.coordinate.longitude
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

extension MDBusinessVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "MDCategoriesCVC", for: indexPath) as! MDCategoriesCVC
        cell.titleLBL.text = categories[indexPath.row]
        if currentCat == categories[indexPath.row]{
            cell.isSelected = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var type = ""
        currentCat = categories[indexPath.row]
        switch currentCat {
        case "Restaurants":
            currentKeyword = "halal"
            type = "restaurant"
            break
        case "Markets":
            currentKeyword = "market"
            type = "market"
            break
        case "Caterers":
            currentKeyword = "caterer"
            type = "caterer"
            break
        case "Business":
            currentKeyword = "business"
            type = "business"
            break
        default:
            type = ""
            currentKeyword = ""
        }
        
        nextToken = ""
        items.removeAll()
        searchArray.removeAll()
        searching = false
        tempText = ""
        myCollectionView.reloadData()
        myTableView.reloadData()
        networkHit(type: type)
    }
}

extension MDBusinessVC {
    
    func setupInitials(){
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(UINib(nibName: "MDCategoriesCVC", bundle: nil), forCellWithReuseIdentifier: "MDCategoriesCVC")
        configureCollectionCell()
        
        myTableView.register(UINib(nibName: "MDItemTVC", bundle: nil), forCellReuseIdentifier: "MDItemTVC")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.tableFooterView = UIView()
        
        locationSettings()
        configureSearchController()
    }
    
    func configureCollectionCell(){
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: 120, height: 55)
        layout2.scrollDirection = .horizontal
        myCollectionView.collectionViewLayout = layout2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isRefreshing) {
            
            isRefreshing = true
            if nextToken != "" {
                networkHit(type: currentCat)
            }
        }
    }
}

extension MDBusinessVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit(type: currentCat)
    }
    
    func networkHit(type: String){
        
        HUD.show(.progress)
        isRefreshing = true
        var meters = 0.0
        if defaults.integer(forKey: "Unit") == 0 {
            meters = (Double(nearbyRange[defaults.integer(forKey: "Distance")])!/0.6213) * 1000
        }else{
            meters = Double(nearbyRange[defaults.integer(forKey: "Distance")])! * 1000
        }
        
        APIRequestUtil.GetMDBusiness(latitude: "\(myLocation.coordinate.latitude)", longitude: "\(myLocation.coordinate.longitude)", radius: "\(meters)", keyword: currentKeyword, type: type, pageToken: nextToken, completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        isRefreshing = false
        if let response = response{
            let json = JSON(response)
            print(json)
            
            nextToken = json["next_page_token"].stringValue
            let results = json["results"].arrayValue
            for i in 0..<results.count {
                let name = results[i]["name"].stringValue
                let vicinity = results[i]["vicinity"].stringValue
                let place_id = results[i]["place_id"].stringValue
                let rating = results[i]["rating"].doubleValue
                
                let geometry = results[i]["geometry"]
                let location = geometry["location"]
                let longs = location["lng"].doubleValue
                let lats = location["lat"].doubleValue
                
                var photoReference = ""
                let photos = results[i]["photos"].arrayValue
                if !photos.isEmpty {
                    let photo = photos.first
                    photoReference = photo?["photo_reference"].stringValue ?? ""
                }
                items.append(MDBusiness(name: name, vicinity: vicinity, photo_reference: photoReference, place_id: place_id, rating: rating, longs: longs, lats: lats))
            }
                                    
            myTableView.reloadData()
            
            if items.count == 0{
                HUD.flash(.label("No Data Found"), delay: 0.7)
            }
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}

extension MDBusinessVC {
    
    func locationSettings(){
        
        if defaults.integer(forKey: "Location") == 1{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "SelectedPlace"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    self.networkHit(type: currentCat)
                }
            } catch { print(error) }
            
        }else if defaults.integer(forKey: "Location") == 2{
            
            do {
                if let data = UserDefaults.standard.data(forKey: "savedLocation"),
                      let SelectedPlace = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SavedLocation {
                    myLocation = CLLocation(latitude: SelectedPlace.latitude, longitude: SelectedPlace.longitude)
                    networkHit(type: currentCat)
                }
            } catch { print(error) }
            
        }else{
            if let location = LocationManager.shared.myLocation {
                myLocation = location
                networkHit(type: currentCat)
            }else{
                observeLocation(object: LocationManager.shared)
                LocationManager.shared.requestLocation()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    @objc func didReceiveNotification(notification: NSNotification){
        if notification.name.rawValue == "LocationFetched" {
            myLocation = LocationManager.shared.myLocation!
            networkHit(type: currentCat)
        }
    }
    
    func observeLocation(object: LocationManager) {
        objectToObserve = object
        if (objectToObserve.myLocation == nil){
            showLocationAlert()
        }else{
            networkHit(type: currentCat)
        }
    }
    
    func showLocationAlert()
    {
        let alertController = UIAlertController(title: "Location Services Off OR No Permission Granted Yet!", message: "Either location services are off OR you did not allow 'My Masajid App' to access your location. Please turn on location services from phone settings for this application or use manual location from application settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                self.navigationController?.popViewController(animated: true)
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MDBusinessVC : UISearchBarDelegate{
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .minimal//UISearchBar.Style.plain
//        searchController.searchBar.barStyle = .black
        searchController.searchBar.barTintColor = .lightGray
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.myTableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""{
            return
        }else{
            searchArray = self.items.filter {
                let country = $0.name.lowercased()
                return country.range(of: searchText.lowercased()) != nil
            }
        }
        myTableView.reloadData()
        tempText = searchBar.text ?? ""
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tempText = ""
        searchBar.text = ""
        searchArray = items
        searching = true
        myTableView.reloadData()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        tempText = ""
        myTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if tempText == "" || tempText == " "{
            searching = false
            tempText = ""
            myTableView.reloadData()
        }else {
            searchBar.text = tempText
        }
    }
}
