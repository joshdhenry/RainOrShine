//
//  WeatherViewControllerSubView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

//This protocol is used for subviews in WeatherViewController
protocol WeatherViewControllerSubView {
    
    // MARK: - Required methods
    func setViewStyle()
    func setViewEdges()
    func fadeIn(withDuration duration: TimeInterval, finalAlpha: CGFloat)
    func fadeOut(withDuration duration: TimeInterval)
}
