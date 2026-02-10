//
//  SettingsProtocol.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 26/09/2020.
//  Copyright © 2020 allMasajid. All rights reserved.
//

import Foundation

protocol SettingsTableViewDelegate {
    func didSelectDropDownItem(sectionIndex : Int, rowIndex : Int, index: Int) -> Void
}
