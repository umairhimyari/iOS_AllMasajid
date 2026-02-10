//
//  GoBackProtocol.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 22/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import Foundation
protocol GoBackProtocol {
    func goBack()
}

protocol PerformActionProtocol {
    func addMasajidPressed()
    func addNonMasajidPressed()
}

protocol SelectOrganizationProtocol {
    func selectOrg(item: MasjidItem)
}
