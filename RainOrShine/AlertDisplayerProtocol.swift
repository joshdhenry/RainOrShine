//
//  AlertDisplayer.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//This protocol is for any view controller that needs to display simple alerts/error messages
protocol AlertDisplayer {
    
    // MARK: - Required methods
    func displaySimpleAlert(title: String, message: String, buttonText: String)
}
