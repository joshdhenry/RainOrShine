//
//  WeatherViewControllerExtensionSettingsUpdatesObserver.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

//Handle notifcations from SettingsDetailTableViewController when settings change
extension WeatherViewController: SettingsUpdatesObserver {
    //Create the observers to catch notifications sent from Settings Detail Table View Controller
    func createSettingsUpdatesObservers() {
        NotificationCenter.default.addObserver(forName: refreshWeatherForecastNotification, object: nil, queue: nil, using: catchRefreshWeatherForecastNotification)
        NotificationCenter.default.addObserver(forName: refreshImageWithNewDefaultPhotosSettingsNotification, object: nil, queue: nil, using: catchRefreshImageWithNewDefaultPhotosSettingsNotification)
    }
    
    
    //Catch notification center notifications
    func catchRefreshWeatherForecastNotification(notification:Notification) -> Void {
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    //If the user has changed the setting that determines how default photos are used in the app, adjust the UI to represent these new settings
    func catchRefreshImageWithNewDefaultPhotosSettingsNotification(notification:Notification) -> Void {
        guard let generalLocalePlace = locationAPIService.generalLocalePlace else {return}
        
        if (generalLocalePlace.photoArray.isEmpty &&
            currentSettings.useDefaultPhotos == .never) {
            resetViewModelImageIndices(resetValue: nil)
        }
        else if (generalLocalePlace.photoArray.isEmpty &&
            currentSettings.useDefaultPhotos == .always ||
            currentSettings.useDefaultPhotos == .whenNoPictures) {
            resetViewModelImageIndices(resetValue: 0)
        }
        else if (!generalLocalePlace.photoArray.isEmpty) {
            resetViewModelImageIndices(resetValue: 0)
        }
    }
}
