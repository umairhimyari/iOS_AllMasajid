//
//  SideMenuProtocol.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 19/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation
import UIKit
import Foundation

protocol SideMenuProtocol {
    func profilePressed()
    func feedbackPressed()
    func logoutPressed()
    func how2UseAppPressed()
}

struct MenuItems {
    var title: String
    var image: UIImage
}
