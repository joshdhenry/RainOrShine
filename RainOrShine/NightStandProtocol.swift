//
//  NightStandProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

protocol NightStand {
    func setNightStandMode()
    func createBatteryStateObserver()
    func batteryStateDidChange(notification: NSNotification)
}
