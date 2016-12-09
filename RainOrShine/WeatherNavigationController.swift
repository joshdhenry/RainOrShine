//
//  WeatherNavigationController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

//The main navigation controller used by the app.
class WeatherNavigationController: UINavigationController {
    
    // MARK: - Properties
    //Determine whether the navigation controller should rotate depending on what Rotation.allowed is
    open override var shouldAutorotate: Bool {
        get {
            return Rotation.allowed
        }
    }
    
    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //This line is needed to avoid ugly graphics artifact in the top right of the navigation bar when segueing to SettingsTableViewController
        self.view.backgroundColor = UIColor.white
    }
}
