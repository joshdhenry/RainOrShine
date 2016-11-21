//
//  UIViewExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // MARK: - Properties
    var allSubViews : [UIView] {
        var array = [self.subviews].flatMap {$0}
        array.forEach { array.append(contentsOf: $0.allSubViews) }
        return array
    }
    
    
    // MARK: - Methods
    public func setViewEdges() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
    }
    
    
    public func fadeIn(withDuration duration: TimeInterval = 2.0, finalAlpha: CGFloat = 0.7) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = finalAlpha
        })
    }
    
    
    public func fadeOut(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        })
    }
    
}
