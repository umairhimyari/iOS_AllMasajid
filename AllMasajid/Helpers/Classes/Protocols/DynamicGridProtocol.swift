//
//  DynamicGridProtocol.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 26/09/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation

protocol DynamicGridLayoutDelegate: AnyObject {
    var cellsPerRow: Int { get set }
    var cellsPerColumn: Int { get set }
    var cellsSpacing: Int { get set }
}
