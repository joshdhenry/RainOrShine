//
//  UIViewExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

extension UIVisualEffectView {
    
    public func setViewEdges() {
        let lightGrayColor = UIColor(netHex: 0xf9f9f9)
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        self.layer.borderColor = lightGrayColor.cgColor
        self.layer.borderWidth = 1
    }
    
    
    func fadeIn(withDuration duration: TimeInterval = 2.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeOut(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        })
    }
    
}
