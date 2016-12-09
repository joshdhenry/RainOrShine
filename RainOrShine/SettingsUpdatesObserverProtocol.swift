//
//  SettingsUpdatesObserverProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//This protocol is used by WeatherViewController to handle notifcations from SettingsDetailTableViewController when settings change
protocol SettingsUpdatesObserver {
    
    // MARK: - Required methods
    func createSettingsUpdatesObservers()
    func catchRefreshWeatherForecastNotification(notification:Notification) -> Void
    func catchRefreshImageWithNewDefaultPhotosSettingsNotification(notification:Notification) -> Void
}
