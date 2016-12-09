//
//  NightStandProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//This protocol is used by WeatherViewController to handle all functions related to Night Stand Mode
protocol NightStand {
    func setNightStandMode()
    func createBatteryStateObserver()
    func batteryStateDidChange(notification: NSNotification)
}
