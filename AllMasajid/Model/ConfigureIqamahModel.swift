//
//  ConfigureIqamahModel.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 05/12/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation

struct PostIqamah {
    var time: String?
    var toDate: String?
    var endDate: String?
}

struct IqamahEntries {
    var isSection: Bool?
    var sectionIndex: Int?
    var cellIndex: Int? // 0 if isSection True
    var time: String?
    var startDate: String?
    var endDate: String?
}
