//
//  NetworkConnectionTester.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

protocol NetworkConnectionTester {
    var currentNetworkConnectionStatus: NetworkConnectionStatus { get }
    
    func alertNoNetworkConnection()
}
