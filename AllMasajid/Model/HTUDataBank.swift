//
//  HTUDataBank.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 27/04/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import Foundation

class HTUDataBank {

    struct HTUDataBankItem {
        var title: String
        var description: String
        var image: String
    }
    
    static let item: [HTUDataBankItem] = [
        
        HTUDataBankItem(title: "Prayer timings", description: "Prayer timings display authentic Salah and Zawal timings country-wise.", image: "htu-prayer-times"),
        HTUDataBankItem(title: "Duaas", description: "Read the legit duaas and Quranic verses to revive your soul with the love of Allah.", image: "htu-duaas-screen"),
        HTUDataBankItem(title: "Duaa Appeal", description: "Duaa of a Muslim for his brother (in Islam) is readily accepted in his absence.[Sahih Muslim]. Make unlimited Duaa appeals through this feature. ", image: "htu-duaa-appeals"),
        HTUDataBankItem(title: "Masajid Nearby", description: "Spot the nearest Masajid within your area by tracking the current location.", image: "htu-masjid-nearby"),
        HTUDataBankItem(title: "My Masajid", description: "Slide in your favourite Masajid in My Masajid to enjoy the latest updates and facilities.", image: "htu-MYMASAJID"),
        HTUDataBankItem(title: "Qibla", description: "Locate a Qibla for Salah at any place.", image: "htu-qibla-direction"),
        HTUDataBankItem(title: "Iqamah", description: "Brace yourself for congregation prayers by tracking Masajid Iqamah timings.", image: "htu-iqamah"),
        HTUDataBankItem(title: "Announcement", description: "Grab the community’s attention by making a live announcement on the allMasajid app.", image: "htu-announcements"),
        HTUDataBankItem(title: "Events", description: "Enjoy the freedom of promoting events free of cost.", image: "htu-events"),
        HTUDataBankItem(title: "Calendar", description: "Fluently mark your WFD, prayer timings, and special events on allMasajid app calendar.", image: "htu-islamic-calendar"),
        HTUDataBankItem(title: "Contribution", description: "Every act of goodness is a charity (Sahih Muslim, Hadith 496).” Gain prosperity in both worlds and start contributing with alMasajid.", image: "htu-contribute-screen"),
        HTUDataBankItem(title: "FAN", description: "Nothing gives more happiness than feeding a needy one. Subscribe to the suitable plan to Feed a Need.", image: "htu-feed_a_need")
    ]
}
