//
//  MDPopSheetVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 17/10/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit

class MDPopSheetVC: UIViewController {
    
    var data: MDBusiness?
    var currentLat = 0.0
    var currentLong = 0.0

    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var myIMG: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var ratingLBL: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let item = data else {return}
        titleLBL.text = item.name
        addressLBL.text = item.vicinity
        ratingLBL.text = "Rating: \(item.rating)"
        
        if item.photo_reference != "" {
            if let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+item.photo_reference) {
                GetImage.getImage(url: url, image: myIMG)
            }
        }else{
            myIMG.image = UIImage(named: "noImagePic")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        popupView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
        blackView.addGestureRecognizer(gestureRecognizer)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(goBackGesture))
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
    }
    
    @IBAction func directionsBtnPressed(_ sender: UIButton) {
        getDirectionsToMasjid()
    }
    
}

extension MDPopSheetVC {
    
    @objc func backgroundTap(gesture : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goBackGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == .down {
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func getDirectionsToMasjid(){
        
        if (UIApplication.shared.canOpenURL(URL(string:"https://www.google.com/maps/")!)) {
            
            UIApplication.shared.open(URL(string:
                                            "https://www.google.com/maps?saddr=\(currentLat),\(currentLong)&daddr=\(String(describing: data?.lats)),\(String(describing: data?.longs))")!, options: [:], completionHandler: nil)
        } else {
            let directionsURL = "http://maps.apple.com/?daddr=\(String(describing: data?.lats)),\(String(describing: data?.longs))&t=m&z=10"
            guard let url = URL(string: directionsURL) else {
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
