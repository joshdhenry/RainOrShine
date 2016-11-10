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
    
    //Determine whether the navigation controller should rotate depending on what Rotation.allowed is
    open override var shouldAutorotate: Bool {
        get {
            return Rotation.allowed
        }
    }
}
