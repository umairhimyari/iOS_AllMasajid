//
//  StoryBoardExtension.swift
//  Lazy Fingers
//
//  Created by Fahad Shafiq on 22/04/2020.
//  Copyright © 2020 Fahad Shafiq. All rights reserved.
//

import Foundation
import UIKit


fileprivate enum Storyboard : String
{
    case auth = "Authentication"
    case options = "Options"
    case settings = "Settings"
    case announcement = "Announcements"
    case event = "Event"
    case main = "Main"
    case faq = "Faq"
    case duas = "Duas"
    case iqam = "Iqamah"
    case cont = "Contribute"
    case notif = "SmartNotifications"
    case md = "MuslimDirectory"
    case ic = "IslamicCalendar"
    case fan = "FeedaNeed"
    case occasions = "Occasions"
    case quran = "Quran"
}


fileprivate extension UIStoryboard {
    
    func load(from Storyboard: Storyboard, _ identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard.init(name: Storyboard.rawValue, bundle: nil)
        let vc = uiStoryboard.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    
    func loadFromStoryBoard(_ type: Storyboard, _ identifier: String) -> UIViewController {
        let vc = load(from: type, identifier)
        return vc
    }
}

//  MARK:- Stories in Main Storyboard
extension UIStoryboard{
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------- Authentication
    // ------------------------------------------------------------------------------------------------

    func LoadLoginScreen() -> LoginViewController
    {
        return self.loadFromStoryBoard(.auth, "LoginViewController") as! LoginViewController
    }
    
    func LoadRegisterScreen() -> RegistrationViewController
    {
        return self.loadFromStoryBoard(.auth, "RegistrationViewController") as! RegistrationViewController
    }
    
    func LoadForgetPasswordScreen() -> ForgetPasswordVC
    {
        return self.loadFromStoryBoard(.auth, "ForgetPasswordVC") as! ForgetPasswordVC
    }
    
    func LoadPreLoginScreen() -> PreLoginVC
    {
        return self.loadFromStoryBoard(.auth, "PreLoginVC") as! PreLoginVC
    }

    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------- Main
    // ------------------------------------------------------------------------------------------------

    func LoadLandingScreen() -> LandingViewController
    {
        return self.loadFromStoryBoard(.main, "LandingViewController") as! LandingViewController
    }
    
    func LoadSideMenuScreen() -> SideMenuVC
    {
        return self.loadFromStoryBoard(.main, "SideMenuVC") as! SideMenuVC
    }
    
    func LoadFeedbackScreen() -> FeedbackViewController
    {
        return self.loadFromStoryBoard(.main, "FeedbackViewController") as! FeedbackViewController
    }
    
    func LoadLoadingScreen() -> LoadingViewController
    {
        return self.loadFromStoryBoard(.main, "LoadingViewController") as! LoadingViewController
    }
    
    func LoadThreeDotScreen() -> ThreeDotVC
    {
        return self.loadFromStoryBoard(.main, "ThreeDotVC") as! ThreeDotVC
    }
    
    func LoadNoInternetScreen() -> NoInternetVC
    {
        return self.loadFromStoryBoard(.main, "NoInternetVC") as! NoInternetVC
    }
    
    func LoadWebViewScreen() -> WebViewVC
    {
        return self.loadFromStoryBoard(.main, "WebViewVC") as! WebViewVC
    }
    
    func LoadTryAgainScreen() -> TryAgainVC
    {
        return self.loadFromStoryBoard(.main, "TryAgainVC") as! TryAgainVC
    }
    
    func LoadVerificationSuccessScreen() -> VerificationSuccessVC
    {
        return self.loadFromStoryBoard(.main, "VerificationSuccessVC") as! VerificationSuccessVC
    }
    
    func LoadAddOptionScreen() -> AddOptionVC
    {
        return self.loadFromStoryBoard(.main, "AddOptionVC") as! AddOptionVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------- Options
    // ------------------------------------------------------------------------------------------------

    func LoadQiblaViewScreen() -> QiblaViewController
    {
        return self.loadFromStoryBoard(.options, "QiblaViewController") as! QiblaViewController
    }
    
    func LoadPrayerTimesScreen() -> PrayerTimesViewController
    {
        return self.loadFromStoryBoard(.options, "PrayerTimesViewController") as! PrayerTimesViewController
    }
    
    func LoadNearbyMasajidScreen() -> NearbyMasajidViewController
    {
        return self.loadFromStoryBoard(.options, "NearbyMasajidViewController") as! NearbyMasajidViewController
    }
    
    func LoadMyMasajidScreen() -> MyMasajidViewController
    {
        return self.loadFromStoryBoard(.options, "MyMasajidViewController") as! MyMasajidViewController
    }
    
    func LoadOrganizationsScreen() -> OrganizationsVC
    {
        return self.loadFromStoryBoard(.options, "OrganizationsVC") as! OrganizationsVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------- Contribute
    // ------------------------------------------------------------------------------------------------
    
    
    func LoadContributeScreen() -> ContributeViewController
    {
        return self.loadFromStoryBoard(.cont, "ContributeViewController") as! ContributeViewController
    }
    
    func LoadContributeSkillsScreen() -> ContributeWithSkillsVC
    {
        return self.loadFromStoryBoard(.cont, "ContributeWithSkillsVC") as! ContributeWithSkillsVC
    }
    
    func LoadContributeTimeScreen() -> ContributeWithTimeVC
    {
        return self.loadFromStoryBoard(.cont, "ContributeWithTimeVC") as! ContributeWithTimeVC
    }
    
    func LoadContributeMoneyScreen() -> ContributeWithMoneyVC
    {
        return self.loadFromStoryBoard(.cont, "ContributeWithMoneyVC") as! ContributeWithMoneyVC
    }
    
    func LoadPaymentScreen() -> PaymentVC
    {
        return self.loadFromStoryBoard(.cont, "PaymentVC") as! PaymentVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------- Events
    // ------------------------------------------------------------------------------------------------
    
    func LoadEventScreen() -> EventsViewController
    {
        return self.loadFromStoryBoard(.event, "EventsViewController") as! EventsViewController
    }
    
    func LoadEventDetailsScreen() -> EventDetailVC
    {
        return self.loadFromStoryBoard(.event, "EventDetailVC") as! EventDetailVC
    }
    
    func LoadAddEventScreen() -> AddEventViewController
    {
        return self.loadFromStoryBoard(.event, "AddEventViewController") as! AddEventViewController
    }
    
    func LoadEventsNewScreen() -> EventsNewVC
    {
        return self.loadFromStoryBoard(.event, "EventsNewVC") as! EventsNewVC
    }
    
    func LoadAddNonMasjidEventScreen() -> AddNonMasjidEventVC
    {
        return self.loadFromStoryBoard(.event, "AddNonMasjidEventVC") as! AddNonMasjidEventVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------- Announcements
    // ------------------------------------------------------------------------------------------------
    
    func LoadAddAnnouncementScreen() -> AddAnnouncementViewController
    {
        return self.loadFromStoryBoard(.announcement, "AddAnnouncementViewController") as! AddAnnouncementViewController
    }
    
    func LoadAnnouncementDetailScreen() -> AnnouncementDetailVC
    {
        return self.loadFromStoryBoard(.announcement, "AnnouncementDetailVC") as! AnnouncementDetailVC
    }
    
    func LoadAnnouncementsScreen() -> AnnouncementsVC
    {
        return self.loadFromStoryBoard(.announcement, "AnnouncementsVC") as! AnnouncementsVC
    }
    
    
    func LoadAnnouncementsNewScreen() -> AnnouncementsNewVC
    {
        return self.loadFromStoryBoard(.announcement, "AnnouncementsNewVC") as! AnnouncementsNewVC
    }
    
    func LoadNonMasajidAnnouncementScreen() -> AddNonMasajidAnnouncementVC
    {
        return self.loadFromStoryBoard(.announcement, "AddNonMasajidAnnouncementVC") as! AddNonMasajidAnnouncementVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------- Settings
    // ------------------------------------------------------------------------------------------------

    func LoadSettingScreen() -> SettingsViewController
    {
        return self.loadFromStoryBoard(.settings, "SettingsViewController") as! SettingsViewController
    }
    
    func LoadDegreeAlertScreen() -> DegreeAlertViewController
    {
        return self.loadFromStoryBoard(.settings, "DegreeAlertViewController") as! DegreeAlertViewController
    }
    
    func LoadProfileScreen() -> ProfileVC
    {
        return self.loadFromStoryBoard(.settings, "ProfileVC") as! ProfileVC
    }
    
    func LoadEditProfileScreen() -> EditProfileVC
    {
        return self.loadFromStoryBoard(.settings, "EditProfileVC") as! EditProfileVC
    }
    
    func LoadChangePasswordScreen() -> ChangePasswordVC
    {
        return self.loadFromStoryBoard(.settings, "ChangePasswordVC") as! ChangePasswordVC
    }
    
    func LoadVerifyOTPScreen() -> VeriftyOtpVC
    {
        return self.loadFromStoryBoard(.settings, "VeriftyOtpVC") as! VeriftyOtpVC
    }
    
    func LoadPhoneVerificationScreen() -> PhoneVerificationVC
    {
        return self.loadFromStoryBoard(.settings, "PhoneVerificationVC") as! PhoneVerificationVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------- FAQ
    // ------------------------------------------------------------------------------------------------

    func LoadFaqScreen() -> faqVC
    {
        return self.loadFromStoryBoard(.faq, "faqVC") as! faqVC
    }
    
    func LoadFaqDetailScreen() -> faqDetailVC
    {
        return self.loadFromStoryBoard(.faq, "faqDetailVC") as! faqDetailVC
    }
    
    func LoadHow2UseCategoryScreen() -> How2UseCategoryVC
    {
        return self.loadFromStoryBoard(.faq, "How2UseCategoryVC") as! How2UseCategoryVC
    }
    
    func LoadHow2UseDetailScreen() -> How2UseDetailVC
    {
        return self.loadFromStoryBoard(.faq, "How2UseDetailVC") as! How2UseDetailVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------- IQAMAH
    // ------------------------------------------------------------------------------------------------

    func LoadIqamahScreen() -> IqamahVC
    {
        return self.loadFromStoryBoard(.iqam, "IqamahVC") as! IqamahVC
    }
    
    func LoadIqamahConfigureScreen() -> IqamahConfigureVC
    {
        return self.loadFromStoryBoard(.iqam, "IqamahConfigureVC") as! IqamahConfigureVC
    }
    
    func LoadJummahIqamahScreen() -> JummahIqamahVC
    {
        return self.loadFromStoryBoard(.iqam, "JummahIqamahVC") as! JummahIqamahVC
    }
    
    func LoadDisplayIqamahScreen() -> DisplayIqamahVC
    {
        return self.loadFromStoryBoard(.iqam, "DisplayIqamahVC") as! DisplayIqamahVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------- Smart Notifications
    // ------------------------------------------------------------------------------------------------

    func LoadSmartNotificationsScreen() -> SmartNotificationsVC
    {
        return self.loadFromStoryBoard(.notif, "SmartNotificationsVC") as! SmartNotificationsVC
    }
    
    func LoadNotificationsListScreen() -> NotificationsListVC
    {
        return self.loadFromStoryBoard(.notif, "NotificationsListVC") as! NotificationsListVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------- Muslim Directory
    // ------------------------------------------------------------------------------------------------

    func LoadMuslimDirectoryHomeScreen() -> MuslimDirectoyHomeVC
    {
        return self.loadFromStoryBoard(.md, "MuslimDirectoyHomeVC") as! MuslimDirectoyHomeVC
    }
    
    func LoadMuslimDirectoryBusinessScreen() -> MDBusinessVC
    {
        return self.loadFromStoryBoard(.md, "MDBusinessVC") as! MDBusinessVC
    }
    
    func LoadMuslimDirectoryPopupScreen() -> MDPopSheetVC
    {
        return self.loadFromStoryBoard(.md, "MDPopSheetVC") as! MDPopSheetVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------- SUPPLICATIONS + REQUEST 4 DUAS
    // ------------------------------------------------------------------------------------------------

    func LoadDailyDuasScreen() -> DailyDuasVC
    {
        return self.loadFromStoryBoard(.duas, "DailyDuasVC") as! DailyDuasVC
    }
    
    func LoadDuasScreen() -> DuasVC
    {
        return self.loadFromStoryBoard(.duas, "DuasVC") as! DuasVC
    }
    
    func LoadFavouriteDuasScreen() -> FavouriteDuasVC
    {
        return self.loadFromStoryBoard(.duas, "FavouriteDuasVC") as! FavouriteDuasVC
    }
    
    func LoadSingleDuasScreen() -> SingleDuaVC
    {
        return self.loadFromStoryBoard(.duas, "SingleDuaVC") as! SingleDuaVC
    }
    
    // --- REQUEST 4 DUAS
    
    func LoadRequest4DuasScreen() -> Request4DuasVC
    {
        return self.loadFromStoryBoard(.duas, "Request4DuasVC") as! Request4DuasVC
    }
    
    func LoadAddDuaRequestScreen() -> AddDuaRequestVC
    {
        return self.loadFromStoryBoard(.duas, "AddDuaRequestVC") as! AddDuaRequestVC
    }
    
    func LoadRequest4DuaDetailScreen() -> Request4DuaDetailsVC
    {
        return self.loadFromStoryBoard(.duas, "Request4DuaDetailsVC") as! Request4DuaDetailsVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------- ISLAMIC CALENDAR
    // ------------------------------------------------------------------------------------------------

    func LoadIslamicCalendarScreen() -> IslamicCalendarVC
    {
        return self.loadFromStoryBoard(.ic, "IslamicCalendarVC") as! IslamicCalendarVC
    }
    
    func LoadHolidaysScreen() -> HolidaysVC
    {
        return self.loadFromStoryBoard(.ic, "HolidaysVC") as! HolidaysVC
    }
    
    func LoadICPrayerTimesScreen() -> ICPrayerTimesVC
    {
        return self.loadFromStoryBoard(.ic, "ICPrayerTimesVC") as! ICPrayerTimesVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------ FEED A NEED
    // ------------------------------------------------------------------------------------------------

    func LoadFanSelectionScreen() -> FanSelectionVC
    {
        return self.loadFromStoryBoard(.fan, "FanSelectionVC") as! FanSelectionVC
    }
    
    
    func LoadFanMasajidScreen() -> FanMasajidVC
    {
        return self.loadFromStoryBoard(.fan, "FanMasajidVC") as! FanMasajidVC
    }
    
    func LoadFanInformationScreen() -> FanInformationVC
    {
        return self.loadFromStoryBoard(.fan, "FanInformationVC") as! FanInformationVC
    }
    
    func LoadFanRegisterMasjidScreen() -> FanRegisterMasjidVC
    {
        return self.loadFromStoryBoard(.fan, "FanRegisterMasjidVC") as! FanRegisterMasjidVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------- Ramadan Special
    // ------------------------------------------------------------------------------------------------

    func LoadRamadanSpecialScreen() -> RamadanSpecialVC
    {
        return self.loadFromStoryBoard(.occasions, "RamadanSpecialVC") as! RamadanSpecialVC
    }
    
    func LoadSelectableOptionsScreen() -> SelectableOptionsVC
    {
        return self.loadFromStoryBoard(.occasions, "SelectableOptionsVC") as! SelectableOptionsVC
    }
    
    func LoadOptionDetailScreen() -> OptionDetailVC
    {
        return self.loadFromStoryBoard(.occasions, "OptionDetailVC") as! OptionDetailVC
    }
    
    // ------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------- Al Quran
    // ------------------------------------------------------------------------------------------------

    func LoadChaptersListing() -> ChaptersListingVC
    {
        return self.loadFromStoryBoard(.quran, "ChaptersListingVC") as! ChaptersListingVC
    }
    
    func LoadChapterDetail() -> ChapterDetailVC
    {
        return self.loadFromStoryBoard(.quran, "ChapterDetailVC") as! ChapterDetailVC
    }
}

