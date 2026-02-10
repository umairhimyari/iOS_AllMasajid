//
//  String+Extensions.swift
//  BaseProject
//
//  Created by Waqas Ali on 29/12/2017.
//  Copyright © 2017 Waqas Ali. All rights reserved.
//

import Foundation
import UIKit

public extension String {
   
    func toDouble() -> Double? {
        return Double(self)
    }
    
    func toFloat() -> Float? {
        return Float(self)
    }
   
    func toInt() -> Int? {
        return Int(self)
    }
    
    // Validate if the string is empty
    func isEmptyStr()->Bool {
        return (self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "");
    }
    
    // Validate if the email is correct
    func isValidEmail()->Bool {
        let emailRegex:String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return predicate.evaluate(with: self);
    }
    
    // Validate if the url is correct
    func isValidUrl() -> Bool {
        let regexURL: String = "(http://|https://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", regexURL)
        return predicate.evaluate(with: self)
    }
    
    // Validate if given input is numeric
    func isNumeric() -> Bool {
        return Double(self) != nil;
    }
    
    // Validate if string has minimum characters
    func isValidForMinChar(noOfChar:Int) -> Bool {
        return (self.utf16.count >= noOfChar);
    }
    
    // Validate if string has less than or equal to maximum characters
    func isValidForMaxChar(noOfChar:Int) -> Bool {
        return (self.utf16.count <= noOfChar);
    }
    
    // Validate the string for given regex
    func isValidForRegex(regex:String) -> Bool {
        let predicate:NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: self);
    }
    
    //extension for getting the domain name from a string
    func getDomain() -> String? {
        guard let url = URL(string: self) else { return nil }
        return url.host
    }
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"),
                
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func getCharAtIndex(_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
}

extension String {
    
    var getMonthName: String {
        let dateArr = self.components(separatedBy: "-")
        if dateArr.count == 3 {
            let month = Int(dateArr[1]) ?? 1
            return EnglishMonths[month - 1]
        }
        return ""
    }
    
    var getDateNo: String {
        let dateArr = self.components(separatedBy: "-")
        if dateArr.count == 3 {
            return dateArr[2]
        }
        return ""
    }
}
