//
//  How2UseDetailVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/02/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

class How2UseDetailVC: UIViewController {
    
    var descriptionReceived = ""
    var imageNameReceived = ""

//    var itemArray = [How2UseAppCategories]()
    var titleReceived = ""
    var screenName = ""
    var screen = 0 // if 1 then pop otherwise dismiss
    
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myPageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLBL.text = "A quick guide on how to use \(titleReceived)"
        myPageControl.isHidden = true
        setupCollectionView()
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        if screen == 0 {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        let pc = sender as! UIPageControl
        
        myCollectionView.scrollToItem(at: IndexPath(item: pc.currentPage, section: 0),
                                    at: .centeredHorizontally, animated: true)
    }
}

extension How2UseDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1//itemArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "How2UseAppCVC", for: indexPath) as! How2UseAppCVC
        
//        cell.configureCellAppSetup(item: itemArray[indexPath.row])
        cell.configureCellAppSetup2(desc: descriptionReceived, image: imageNameReceived)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.myCollectionView.frame.width, height: self.myCollectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        myPageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func setupCollectionView(){
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(UINib(nibName: "How2UseAppCVC", bundle: nil), forCellWithReuseIdentifier: "How2UseAppCVC")
        
        self.myPageControl.numberOfPages = 1//itemArray.count
//        networkHit()
    }
}
/*
extension How2UseDetailVC: TryAgainProtocol{
    
    func tryAgain() {
        networkHit()
    }
    
    func networkHit(){
        HUD.show(.progress)
        APIRequestUtil.GetHow2UseDetail(screenName: screenName, headers: [:], completion: APIRequestCompleted)
    }
    
    fileprivate func APIRequestCompleted(response: Any?, error: Error?) {
        HUD.hide()
        if let response = response{
            let json = JSON(response)
            print(json)
            
            itemArray.removeAll()
            
            for index in 0..<json.count{
                let model = How2UseAppCategories(fromJson: json[index])
                itemArray.append(model)
            }
            
            itemArray.sort{ $0.order < $1.order }
            self.myPageControl.numberOfPages = itemArray.count
            
            myCollectionView.reloadData()
            
        }else{
            let vc = UIStoryboard().LoadTryAgainScreen()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.parent?.present(vc, animated: false, completion: nil)
        }
    }
}
*/
