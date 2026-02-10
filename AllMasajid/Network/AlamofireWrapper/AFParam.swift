//
//  AFRequestParam.swift
//  BaseProject
//
//  Created by Fahad Ajmal on 31/01/2018.
//  Copyright © 2018 M.Fahad Ajmal. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

//request param for call
public struct AFParam {
    var endpoint: String = ""
    var params: Parameters?
    var headers: [String : String]?
    var method: HTTPMethod
    var images: [UIImage]?
    var parameterEncoding: ParameterEncoding
    
    public init(endpoint:String, params: Parameters, headers: [String : String], method: HTTPMethod, parameterEncoding: ParameterEncoding, images: [UIImage]) {
        self.endpoint = endpoint
        self.params = params
        self.headers = headers
        self.method = method
        self.images = images
        self.parameterEncoding = parameterEncoding
    }
}

