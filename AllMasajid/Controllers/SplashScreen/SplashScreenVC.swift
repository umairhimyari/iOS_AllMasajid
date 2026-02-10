//
//  SplashScreenVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 19/06/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SplashScreenVC: UIViewController {

    // Flag to ensure animation and navigation only run once
    private var hasAnimated = false
    private var hasNavigated = false

    var hadithTexts: [String] = [
        "The believe's shade on the Day of Resurrection will be his charity. (Al-Tirmidhi)",
        "When a man dies, his deeds comes to an end except for three things: Sadaqah Jariyah; a knowledge which is beneficial, or a virtuous descendant who prays for him.",
        "Nothing is more honorable to Allah the Most-High than Dua. (Sahih al-Jami)",
        "Prescribed for you when death approaches [any] one of you if he leaves wealth [is that he should make] a bequest for the parents and near relatives according to what is acceptable - a duty upon the righteous. (The Quran 2:180)",
        "Narrated by Abu Huraira (R.A): Prophet Muhammad said, Whoever observes fast during the month of Ramadan out of sincere faith and hoping to attain Allah's reward then all his past sins will be forgiven.",
        "Abu Huraira (R.A) reported Allah's apostle's saying that: when a man dies, his acts come to an end, but three recurring charity, or knowledge (by which people) benefit, or a pion son, who prays for him (for the deceased).",
        "Reduction from fifty prayers to five prayers (Al-Miraj)",
        "Exalted is He who took His Servant by night from al-Masjid al-Haram to al-Masjid al-Aqsa, whose surroundings We have blessed, to show him of Our signs. Indeed, He is the Hearing, the Seeing. (Surah Al-Isra)",
        "Protect yourself from the hellfire, even donating half of the date fruit in charity [Sahih Al-Bukhari]. The small amount of charity is also counted in Islam and generates higher rewards.",
        "Allah will double the rewards and remove misery for the person who spends on charity. So why not we contribute from the wealth provided by Allah?"
    ]

    @IBOutlet weak var allMLogoIMG: UIImageView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var hadithLBL: UILabel!
    @IBOutlet weak var loaderVIew: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let randomInt = Int.random(in: 0..<hadithTexts.count)
        hadithLBL.text = hadithTexts[randomInt]

        // Initially hide popup and black view
        popupView.isHidden = true
        blackView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Only run animation once
        guard !hasAnimated else { return }
        hasAnimated = true

        startSplashAnimation()
    }

    private func startSplashAnimation() {
        UIView.animate(withDuration: 1.0, animations: {
            self.allMLogoIMG.frame.origin.y -= 90
        }) { _ in
            self.popupView.isHidden = false
            self.blackView.isHidden = false
            self.loaderVIew.startAnimating()

            // Navigate after delay - only once
            self.scheduleNavigation()
        }
    }

    private func scheduleNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self = self, !self.hasNavigated else { return }
            self.hasNavigated = true

            self.loaderVIew.stopAnimating()
            let vc = UIStoryboard().LoadLandingScreen()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
