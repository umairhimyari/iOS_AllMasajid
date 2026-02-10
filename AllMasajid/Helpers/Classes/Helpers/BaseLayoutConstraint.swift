//
//  BaseLayoutConstraint.swift
//  TrafficFramework
//
//  Created by Faraz Hussain Siddiqui on 8/13/17.
//  Copyright © 2017 Faraz Hussain Siddiqui. All rights reserved.
//

import UIKit
/*
open class BaseLayoutConstraint: NSLayoutConstraint {
    
    override open func awakeFromNib() {
        
        super.awakeFromNib();
        self.constant = DesignUtility.convertToRatio(constant, sizedForIPad: false, sizedForNavi:false)
        
    }
}

public extension NSLayoutConstraint {
    @IBInspectable var setConstraint: CGFloat {
        get { return constant }
        set {
            constant = DesignUtility.getValueFromRatio(newValue)
        }
    }
}

public extension UIView {
    
    func topConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .top)
    }
    
    func bottomConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .bottom)
    }
    
    
    func leadingConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .leading)
    }
    
    func traillingConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .trailing)
    }
    
    
    func leftConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .left)
    }
    
    func rightConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .right)
    }
    
    func centerXConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .centerX)
    }
    
    func centerYConstraint() -> NSLayoutConstraint {
        
        return getOriginConstraint(type: .centerY)
    }
    
    
    func heightConstraint() -> NSLayoutConstraint {
        
        return getSizeConstraint(type: .height)
    }
    
    
    func widthConstraint() -> NSLayoutConstraint {
        
        return getSizeConstraint(type: .width)
    }
    
    private func getOriginConstraint( type : NSLayoutConstraint.Attribute) -> NSLayoutConstraint{
        
        
        for constraint in (self.superview?.constraints)! {
            
            if constraint.firstItem  as? UIView == self && constraint.firstAttribute == type{
                return constraint
            }
            else {
                if constraint.secondItem as? UIView == self && constraint.secondAttribute == type {
                    return constraint
                }
            }
        }
        
        return NSLayoutConstraint()
    }
    
    
    func getSizeConstraint( type : NSLayoutConstraint.Attribute) -> NSLayoutConstraint{
        
        for constraint in self.constraints {
            if  constraint.firstAttribute == type{
                return constraint
            }
        }
        return NSLayoutConstraint()
    }
    
    private func log(_ text : NSLayoutConstraint.Attribute){
        print("NO \(text) Constraint Found")
    }
}
*/
