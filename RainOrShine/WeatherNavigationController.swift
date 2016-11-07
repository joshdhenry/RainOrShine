//
//  WeatherNavigationController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

class WeatherNavigationController: UINavigationController {
    
    open override var shouldAutorotate: Bool {
        get {
            return Rotation.allowed
        }
    }
}
