//
//  File.swift
//  Global Paint
//
//  Created by Apple on 01/09/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class APIResponseUtil {
    
    public static func isValidResponse(viewController: UIViewController,
                                       response: Any?, error: Error?, renderError: Bool = false,
                                       dismissLoading: Bool = true) -> Bool {
        
        var isValidResponse = false

        
        
        if error != nil {
            print("Something went wrong")

        } else {
            
            if response != nil {

              let json = JSON(response!)
              let dic = json.dictionary

              print(json)

              let status = dic!["status"]?.boolValue

              if(status!)
              {

                 isValidResponse = true

              }else{
                
                var error = ""
                print(error)
                if let err = dic!["Error"]?.array{
                    error = err[0].stringValue
                }
                
                if let err = dic!["Error"]?.stringValue{
                    error = err
                }
                
                if let err = dic!["message"]?.stringValue{
                    error = err
                }
                
                if let err = dic!["Errors"]?.array{
                    if(err.count>0){
                    error = err[0].stringValue
                    }
                }
                
                isValidResponse = false

              }
            }
        }
        return isValidResponse
    }
}
