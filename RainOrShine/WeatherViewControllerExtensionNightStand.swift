//
//  WeatherViewControllerExtensionNightStand.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

//Handle all functions related to Night Stand Mode
extension WeatherViewController: NightStand {
    //Turn on or off the screen lock depending on the charging status and whether night stand mode is on/off in Settings
    internal func setNightStandMode() {
        if (currentSettings.nightStandModeOn == true &&
            UIDevice.current.batteryState == UIDeviceBatteryState.charging ||
            UIDevice.current.batteryState == UIDeviceBatteryState.full) {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    //Begin monitoring charging state.
    internal func createBatteryStateObserver() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: Notification.Name.UIDeviceBatteryStateDidChange, object: nil)
    }
    
    
    //If the battery state changes, turn on or off the screen lock accordingly
    dynamic func batteryStateDidChange(notification: NSNotification){
        setNightStandMode()
    }
}
