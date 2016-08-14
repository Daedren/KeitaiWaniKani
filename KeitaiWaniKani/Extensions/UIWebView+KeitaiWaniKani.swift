//
//  UIWebView+KeitaiWaniKani.swift
//  KeitaiWaniKani
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import UIKit

private var swizzledClassMapping: [AnyClass] = []

extension UIWebView {
    // Adapted from http://stackoverflow.com/questions/19033292/ios-7-uiwebview-keyboard-issue?lq=1
    func noInputAccessoryView() -> UIView? {
        return nil
    }
    
    func removeInputAccessoryView() {
        guard let subview = scrollView.subviews.filter({ NSStringFromClass($0.dynamicType).hasPrefix("UIWeb") }).first else {
            return
        }
        
        // Guard in case this method is called twice on the same webview.
        guard !(swizzledClassMapping as NSArray).contains(subview.dynamicType) else {
            return
        }
        
        let className = "\(subview.dynamicType)_SwizzleHelper"
        var newClass: AnyClass? = NSClassFromString(className)
        
        if newClass == nil {
            newClass = objc_allocateClassPair(subview.dynamicType, className, 0)
            
            guard newClass != nil else {
                return
            }
            
            let method = class_getInstanceMethod(self.dynamicType, #selector(noInputAccessoryView))
            class_addMethod(newClass!, #selector(getter: UIResponder.inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method))
            
            objc_registerClassPair(newClass!)
            
            swizzledClassMapping += [newClass!]
        }
        
        object_setClass(subview, newClass!)
    }
    
    // http://stackoverflow.com/questions/28631317/how-to-disable-scrolling-entirely-in-a-wkwebview
    func setScrollEnabled(_ enabled: Bool) {
        self.scrollView.isScrollEnabled = enabled
        self.scrollView.panGestureRecognizer.isEnabled = enabled
        self.scrollView.bounces = enabled
        
        for subview in self.subviews {
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = enabled
                subview.bounces = enabled
                subview.panGestureRecognizer.isEnabled = enabled
            }
        }
    }
    
    func scrollToTop(_ animated: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: animated)
    }

}
