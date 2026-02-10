//
//  UtilityExtensions.swift
//  TrafficFramework
//
//  Created by Faraz Hussain Siddiqui on 8/13/17.
//  Copyright © 2017 Faraz Hussain Siddiqui. All rights reserved.
//

import Foundation
import UIKit

extension RawRepresentable {
    
    init?(raw: RawValue?) {
        guard let raw = raw else {
            return nil
        }
        self.init(rawValue: raw)
    }
    
    init(raw: RawValue?, defaultValue: Self) {
        guard let value = raw  else {
            self = defaultValue
            return
        }
        self = Self(rawValue: value) ?? defaultValue
    }
}

func iterateEnum<T: Hashable>(from: T.Type) -> AnyIterator<T> {
    var x = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &x) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        defer {
            x += 1
        }
        return next.hashValue == x ? next : nil
    }
}

extension UIImage{
    
    convenience init(setImageForPro:String){
        // dont forget to add if statement for pro
        
        if DeviceUtility.isIpad(){
            
            self.init(named: "\(setImageForPro)")!
            
            
        }
        else{
            self.init(named: setImageForPro)!
            
            
        }
        
    }
    
    
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0);
        context!.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context!.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    
}


