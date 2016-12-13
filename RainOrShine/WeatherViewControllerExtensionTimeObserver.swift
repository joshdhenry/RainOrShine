//
//  WeatherViewControllerExtensionTimeObserver.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

//Handle all timers for WeatherViewController
extension WeatherViewController: TimeObserver {
    
    // MARK: - Methods
    
    //Create a time observer to run every 10 minutes to refresh the weather forecast
    internal func createTimeObservers() {
        //Create the update weather forecast timer
        let weatherUpdateMinutes: Int = currentSettings.updateWeatherInterval.rawValue.intFromPlainEnglish
        let updateWeatherTimeInterval: TimeInterval = Double(weatherUpdateMinutes * 60)
        
        //If it is not 0 ("Never"), start a timer to update the weather
        if (updateWeatherTimeInterval != 0) {
            updateWeatherTimer = Timer.scheduledTimer(timeInterval: updateWeatherTimeInterval, target: self, selector: #selector(self.timeIntervalReached), userInfo: "UpdateWeather", repeats: true)
        }
        
        //Create the change photo timer
        let photoIntervalMinutes: Int = currentSettings.changePhotoInterval.rawValue.intFromPlainEnglish
        let changePhotoTimeInterval: TimeInterval = Double(photoIntervalMinutes * 60)
        
        //If it is not 0 ("Never"), start a timer to change the photo
        if (changePhotoTimeInterval != 0) {
            changePhotoTimer = Timer.scheduledTimer(timeInterval: changePhotoTimeInterval, target: self, selector: #selector(self.timeIntervalReached), userInfo: "ChangePhoto", repeats: true)
        }
    }
    
    
    //Invalidate all of the time observers.  When the user returns from settings, all timers will be reset to whatever is in stored settings
    internal func destroyTimeObservers() {
        updateWeatherTimer.invalidate()
        changePhotoTimer.invalidate()
    }
    
    
    //This is called when a time observer's time has been reached.
    dynamic func timeIntervalReached(timer: Timer) {
        guard let userInfo = timer.userInfo as? String else {
            NSLog("Error - Time interval user info tag was nil.")
            return
        }
        
        switch (userInfo) {
        case "UpdateWeather":
            guard (currentNetworkConnectionStatus != .notReachable) else {return}
            
            loadNewPlaceWeather() { (isComplete) -> () in
                if (isComplete) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        case "ChangePhoto":
            guard let currentGeneralLocalePlace = locationAPIService.generalLocalePlace else {return}
            
            if (!currentGeneralLocalePlace.photoArray.isEmpty) {
                let currentPageNumber: Int = self.photoDetailView.advancePage(direction: UISwipeGestureRecognizerDirection.left, place: currentGeneralLocalePlace, looping: true)
                locationImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
                appLogoImageView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: currentPageNumber, place: currentGeneralLocalePlace)
            }
        default:
            NSLog("Error - Time interval user info tag was not recognized.")
            return
        }
    }
}
