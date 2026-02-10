//
//  GetImage.swift
//  PCMA
//
//  Created by Fahad Shafiq on 07/06/2020.
//  Copyright © 2020 Fahad Shafiq. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class GetImage {
    public static func getImage(url: URL, image: UIImageView){
        
        image.kf.indicatorType = .activity
        image.kf.setImage(
           with: url,
           placeholder: UIImage(named: "allMlogo"),
           options: [
               //.forceRefresh,
               .scaleFactor(UIScreen.main.scale),
               .transition(.fade(1)),
            ]
        )
    }
}

