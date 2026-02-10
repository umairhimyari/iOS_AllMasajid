//
//  WebViewVC.swift
//  AllMasajid
//
//  Created by Fahad Shafiq on 01/01/2021.
//  Copyright © 2021 allMasajid. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

// About Us = 1
// Terms & Conditions = 2

class WebViewVC: UIViewController {

    // Use HTTPS to comply with App Transport Security
    var baseURLWeb: String = "https://www.allmasajid.com/"

    var screenReceived = 0
    var webURL = ""
    var webTitle = ""

    // Timeout timer for loading
    private var loadingTimer: Timer?
    private let loadingTimeout: TimeInterval = 15.0

    @IBOutlet weak var myWebView: WKWebView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var topTitleLBL: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitials()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.footerView.addGestureRecognizer(tap)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingTimer?.invalidate()
        loadingTimer = nil
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func threeDotPressed(_ sender: UIButton) {
        let vc = UIStoryboard().LoadThreeDotScreen()
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.screen = "item8"
        self.parent?.present(vc, animated: false, completion: nil)
    }

    private func startLoadingTimeout() {
        loadingTimer?.invalidate()
        loadingTimer = Timer.scheduledTimer(withTimeInterval: loadingTimeout, repeats: false) { [weak self] _ in
            self?.handleLoadingTimeout()
        }
    }

    private func handleLoadingTimeout() {
        HUD.hide()
        showLoadingError(message: "The page is taking too long to load. Please check your internet connection and try again.")
    }

    private func showLoadingError(message: String) {
        let alert = UIAlertController(title: "Loading Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.retryLoading()
        })
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func retryLoading() {
        guard let url = URL(string: webURL) else { return }
        HUD.show(.progress)
        startLoadingTimeout()
        myWebView.load(URLRequest(url: url))
    }
}

extension WebViewVC: WKNavigationDelegate {
    
    func setupInitials() {
        
        self.navigationController?.navigationBar.isHidden = false
        
        if screenReceived == 1 { // About Us
            webTitle = "About Us"
            webURL = baseURLWeb + "about"
            
        } else if screenReceived == 2 { // Terms & Conditions
            webTitle = "Terms & Conditions"
            webURL = baseURLWeb + "terms-and-conditions"
        }
        
        print("Loading URL: \(webURL)")
        topTitleLBL.text = webTitle
        
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
        
        // Configure webview for better loading
        let configuration = myWebView.configuration
        configuration.allowsInlineMediaPlayback = true
        
        guard let url = URL(string: webURL) else {
            showLoadingError(message: "Invalid URL. Please try again later.")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = loadingTimeout
        myWebView.load(request)
        startLoadingTimeout()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingTimer?.invalidate()
        loadingTimer = nil
        HUD.hide()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        HUD.show(.progress)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingTimer?.invalidate()
        loadingTimer = nil
        HUD.hide()
        print("WebView didFail error: \(error.localizedDescription)")
        showLoadingError(message: "Failed to load page: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingTimer?.invalidate()
        loadingTimer = nil
        HUD.hide()
        print("WebView didFailProvisionalNavigation error: \(error.localizedDescription)")
        showLoadingError(message: "Unable to connect. Please check your internet connection and try again.")
    }
}

extension WebViewVC: ThreeDotProtocol {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let url = URL(string: allMWebURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func faqBtnPressed() {
        print("Do nothing")
    }
    
    func feedbackBtnPressed() {
        let vc = UIStoryboard().LoadFeedbackScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpBtnPressed(){
        guard let url = URL(string: helpURL) else { return }
        UIApplication.shared.open(url)
    }
    
    func refreshBtnPressed() {
        print("Do nothing")
    }
    
    func shareBtnPressed() {
        print("Do nothing")
    }
    
    func addBtnPressed() {
        print("No Nothing")
    }
    
    func favouritesBtnPressed(){
        print("No Nothing")
    }
    
    func aboutUsBtnPressed(){
        print("No Nothing")
    }
}
