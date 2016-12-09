//
//  TimeObserverProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//This protocol can be used by anything that uses timers
protocol TimeObserver {
    
    // MARK: - Required methods
    func createTimeObservers()
    func destroyTimeObservers()
    func timeIntervalReached(timer: Timer)
}
