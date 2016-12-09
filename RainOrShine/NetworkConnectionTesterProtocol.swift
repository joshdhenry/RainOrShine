//
//  NetworkConnectionTester.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//Used for any object that needs to know whether the device is online or not
protocol NetworkConnectionTester {
    
    // MARK: - Required properties
    var currentNetworkConnectionStatus: NetworkConnectionStatus { get }
    
    // MARK: - Required methods
    func alertNoNetworkConnection()
}
