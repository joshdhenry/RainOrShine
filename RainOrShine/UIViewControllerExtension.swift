//
//  UIViewControllerExtensionNetworkConnectionTester.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import SystemConfiguration
import UIKit

enum NetworkConnectionStatus {
    case notReachable
    case reachableViaWWAN
    case reachableViaWiFi
}

extension UIViewController: NetworkConnectionTester {

    var currentNetworkConnectionStatus: NetworkConnectionStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // Wireless Wide Area Network (WWAN) interface such as EDGE or 3G
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
    
    internal func alertNoNetworkConnection() {
        let networkConnectionAlert = UIAlertController(title: "No Network Connection", message: "No network connection available. Please connect to the Internet and try again.", preferredStyle: .alert)
        networkConnectionAlert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(networkConnectionAlert, animated: true, completion: nil)
    }
}
