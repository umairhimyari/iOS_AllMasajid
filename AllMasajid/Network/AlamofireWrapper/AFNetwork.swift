//
//  AFNetwork.swift
//  BaseProject
//
//  Created by Fahad Ajmal on 01/11/2017.
//  Copyright © 2018 M.Fahad Ajmal. All rights reserved.
//

import UIKit
import Alamofire
/*
public class AFNetwork: NSObject {
    
    //MARK: constant and variable
    //manager
    public var alamoFireManager: Alamofire.SessionManager!
    public var failureMessage = "Unable to connect to the internet"
    
    //network
    public var baseURL = "http://web.allmasajid.com/api/v1/"
    public var feedBackURL = "http://dashboard.allmasajid.org/api/"
    public var hbaseURL = "http://www.allmasajid.com/"
    public var commonHeaders: Dictionary<String, String> = [:]
    
    //spinner
    struct spinnerViewConfig {
        static let tag: Int = 98272
        static let color = UIColor.white
    }
    
    //progress view
    public var progressLabel: UILabel?
    var progressView: UIProgressView?
    struct progressViewConfig {
        static let tag: Int = 98273
        static let color = UIColor.white
        static let labelColor = UIColor.red
        static let trackTintColor = UIColor.red
        static let progressTintColor = UIColor.green
    }
    
    //shared Instance
    public static let shared: AFNetwork = {
        let instance = AFNetwork()
    
        return instance
    }()
    
    // MARK: - : override
    override init() {
     
        alamoFireManager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default
        )
        alamoFireManager.session.configuration.timeoutIntervalForRequest = 90
    }
    
    //setupSSL
    public func setupSSLPinning(_ fileNameInBundle: String) {
        
        // Set up certificates
        let pathToCert = Bundle.main.path(forResource: fileNameInBundle, ofType: "crt")
        let localCertificate = NSData(contentsOfFile: pathToCert!)
        let certificates = [SecCertificateCreateWithData(nil, localCertificate!)!]
        
        // Configure the trust policy manager
        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
            certificates: certificates,
            validateCertificateChain: true,
            validateHost: true
        )
        
        let serverTrustPolicies = [
            AFNetwork.shared.baseURL.getDomain() ?? AFNetwork.shared.baseURL : serverTrustPolicy
        ]
        
        alamoFireManager =
            Alamofire.SessionManager(
                configuration: URLSessionConfiguration.default,
                serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
}

// MARK: - Request
extension AFNetwork {
    
    //general request
    public func apiRequest(_ info: AFParam, isSpinnerNeeded: Bool, success:@escaping (Data?) -> Void, failure:@escaping (Error) -> Void) {
        
        //if spinner needed
        if isSpinnerNeeded && !info.endpoint.contains("wp-json/islamicdate/all") {
            DispatchQueue.main.async {
                AFNetwork.shared.showSpinner(nil)
            }
        }
        
        var baseurL = baseURL
        if info.endpoint.contains("wp-json/islamicdate/all"){
            baseurL = self.hbaseURL
        }else if info.endpoint.contains("feedback/create"){
            baseurL = feedBackURL
        }
        
        if info.endpoint.contains("wp-json/islamicdate/all"){
            
             alamoFireManager.request(baseurL + info.endpoint, method: info.method, parameters: info.params, headers: mergeWithCommonHeaders(info.headers)).responseJSON { (response) -> Void in
                
                //remove spinner
                if isSpinnerNeeded {
                    DispatchQueue.main.async {
                        AFNetwork.shared.hideSpinner()
                    }
                }
                
                //check response result case
                switch response.result {
                case .success:
                    //debugPrint(response.result.value!)
                    success(response.data)
                case .failure:
                    let error : Error = response.result.error!
                    //debugPrint("responseError: \(error)")
                  //  Alert.showMsg(msg: error.localizedDescription)
                    failure(error)
                }
            }
            
        }else{
            
            print(baseurL + info.endpoint)
             alamoFireManager.request(baseurL + info.endpoint, method: info.method, parameters: info.params, encoding: info.parameterEncoding, headers: mergeWithCommonHeaders(info.headers)).responseJSON { (response) -> Void in
                
                
                //remove spinner
                if isSpinnerNeeded {
                    DispatchQueue.main.async {
                        AFNetwork.shared.hideSpinner()
                    }
                }
                
                //check response result case
                switch response.result {
                case .success:
                    //debugPrint(response.result.value!)
                    success(response.data)
                case .failure:
                    let error : Error = response.result.error!
                    //debugPrint("responseError: \(error)")
                  //  Alert.showMsg(msg: error.localizedDescription)
                    failure(error)
                }
            }
        }
    }
}


// MARK: - Progress and spinner methods
extension AFNetwork {
    
    public func showProgressView(_ customView: UIView?) {
        
        var window = customView
        
        if (window == nil) {
            window = returnTopWindow()
        }
        if window?.viewWithTag(progressViewConfig.tag) != nil {
            return
        }
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.tag = progressViewConfig.tag
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
        
        let progressContainer = UIView()
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.backgroundColor = UIColor.clear
        
        progressLabel = UILabel()
        progressLabel?.translatesAutoresizingMaskIntoConstraints = false
        progressLabel?.textColor = progressViewConfig.labelColor
        progressLabel?.text = "Upload progress 0%"
        progressLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold)
        progressLabel?.adjustsFontSizeToFitWidth = true
        progressLabel?.textAlignment = .center
        progressContainer.addSubview(progressLabel!)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.translatesAutoresizingMaskIntoConstraints = false
        progressView?.progressTintColor = progressViewConfig.progressTintColor
        progressView?.trackTintColor = progressViewConfig.trackTintColor
        progressView?.progress = 0.0
        progressContainer.addSubview(progressView!)
        
        progressContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[progressView]-(10)-[progressLabel]|", options: [], metrics: nil, views: ["progressLabel" : progressLabel!, "progressView" : progressView!]))
        progressContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressView(200)]|", options: [], metrics: nil, views: ["progressView" : progressView!]))
        progressContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressLabel]|", options: [], metrics: nil, views: ["progressLabel" : progressLabel!]))
        backgroundView.addSubview(progressContainer)
        
        backgroundView.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: progressContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        backgroundView.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: progressContainer, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        window?.addSubview(backgroundView)
        window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView" : backgroundView]))
        window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView" : backgroundView]))
    }
    
    //hide progress view
    public func hideProgressView() {
        
        let window: UIWindow? = returnTopWindow()
        window?.viewWithTag(progressViewConfig.tag)?.removeFromSuperview()
        progressLabel = nil
        progressView = nil
    }
    
    //show spinner
    public func showSpinner(_ customView: UIView?) {
        
        var window = customView
        
        if (window == nil) {
            window = returnTopWindow()
        }
        if ((window?.viewWithTag(spinnerViewConfig.tag)) != nil) {
            return
        }
        
        //background view
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.tag = spinnerViewConfig.tag
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        window?.addSubview(backgroundView)
        window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView" : backgroundView]))
        window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView" : backgroundView]))
        
        //spinner
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = spinnerViewConfig.color
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        backgroundView.addSubview(activityIndicator)
        backgroundView.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        backgroundView.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    //hide spinner
    public func hideSpinner() {
        
        let window: UIWindow? = returnTopWindow()
        window?.viewWithTag(spinnerViewConfig.tag)?.removeFromSuperview()
    }
}

// MARK: - Helper methods
extension AFNetwork {
    
    //set progress and text of progress view
    func setProgressProgress(_ fractionCompleted:Float) {
        
        self.progressView?.progress = Float(fractionCompleted)
        self.progressLabel?.text = String(format: "Uploading Image %.0f%%", fractionCompleted * 100)
    }
    
    //return top window
    func returnTopWindow() -> UIWindow {
        
        let windows: [UIWindow] = UIApplication.shared.windows
        
        for topWindow: UIWindow in windows {
            if topWindow.windowLevel == UIWindow.Level.normal {
                return topWindow
            }
        }
        return UIApplication.shared.keyWindow!
    }
    
    //return merge headers
    func mergeWithCommonHeaders(_ headers: [String : String]?) -> Dictionary<String, String> {
        
        if headers != nil {
            for header in headers! {
                AFNetwork.shared.commonHeaders[header.key] = header.value
            }
        }
        return AFNetwork.shared.commonHeaders
    }
}


*/
