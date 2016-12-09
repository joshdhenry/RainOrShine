//
//  WeatherViewControllerExtensionLocationLoader.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//Handle all duties related to loading in a new location in WeatherViewController.
extension WeatherViewController: LocationLoader {
    
    //Start the process of finding current GPS location.  Once it begins updating, the location manager's didUpdateLocation method will take control from there
    func startFindingCurrentLocation(alertsEnabled: Bool) {
        guard (currentNetworkConnectionStatus != .notReachable) else {
            if (alertsEnabled) {
                alertNoNetworkConnection()
            }
            return
        }
        
        guard (CLLocationManager.locationServicesEnabled()) else {
            if (alertsEnabled) {
                displaySimpleAlert(title: "GPS Not Enabled", message: "Location services are not enabled on this device.  Go to Settings -> Privacy -> Location Services and enable location services.", buttonText: "OK")
            }
            return
        }
        
        guard (CLLocationManager.authorizationStatus() != .denied ||
            CLLocationManager.authorizationStatus() != .restricted ||
            CLLocationManager.authorizationStatus() != .notDetermined) else {
                if (alertsEnabled) {
                    displaySimpleAlert(title: "GPS Not Enabled", message: "GPS is not enabled for this app.  Go to Settings -> Privacy -> Location Services and allow the app to utilize GPS.", buttonText: "OK")
                }
                return
        }
        
        guard (CLLocationManager.authorizationStatus() != .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() != .authorizedAlways) else {
                return
        }
        
        startChangingGPSPlaceShown()
    }
    
    
    //This method updates the location by running setCurrentExactPlace and setGeneralLocalePlace.  It is only called when the user taps the GPS current location button.
    func updateLocationAPIServiceLocations() {
        makeSubViewsInvisible()
        
        locationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound) {
                self.photoDetailView.viewModel?.updatePlace(newPlace: locationPlace)
                
                self.locationAPIService.currentPlace = locationPlace
                
                //Set the general locale of the place (better for pictures and displaying user's location than exact addresses)
                self.locationAPIService.setGeneralLocalePlace() { (isGeneralLocaleFound, generalLocalePlace) -> () in
                    if (isGeneralLocaleFound) {
                        self.locationView.viewModel?.updateGeneralLocalePlace(newPlace: generalLocalePlace)
                        
                        self.locationAPIService.generalLocalePlace = generalLocalePlace
                        
                        self.changePlaceShown()
                    }
                }
            }
        }
    }
    
    
    //Change the place that will be displayed in this view controller (including new place photos and weather forecast)
    func changePlaceShown() {
        print("Exact place address - \(locationAPIService.currentPlace?.gmsPlace?.formattedAddress)")
        print("General location address - \(locationAPIService.generalLocalePlace?.gmsPlace?.formattedAddress)")
        
        var changePlaceCompletionFlags = (photosComplete: false, weatherComplete: false)
        
        resetValuesForNewPlace()
        
        //Run 2 methods - loadNewPlacePhotos & loadNewPlaceWeather. Once both are complete, run finishChangingPlaceShown to complete the process
        loadNewPlacePhotos() { (isComplete) -> () in
            if (isComplete) {
                changePlaceCompletionFlags.photosComplete = true
                if (changePlaceCompletionFlags.weatherComplete) {
                    DispatchQueue.main.async {
                        self.finishChangingPlaceShown()
                    }
                }
            }
        }
        loadNewPlaceWeather() { (isComplete) -> () in
            if (isComplete) {
                changePlaceCompletionFlags.weatherComplete = true
                if (changePlaceCompletionFlags.photosComplete) {
                    DispatchQueue.main.async {
                        self.finishChangingPlaceShown()
                    }
                }
            }
        }
    }
    
    
    //Start changing the place shown when the GPS button is tapped
    private func startChangingGPSPlaceShown() {
        currentLocationButton.isEnabled = false
        activityIndicator.startAnimating()
        locationSearchView.isUserInteractionEnabled = false
        validGPSConsecutiveSignalsReceived = 0
        locationManager.startUpdatingLocation()
    }
    
    
    //Perform final actions to complete the transition to a new place. This applies to finishing GPS locations and Google Place Search locations.
    private func finishChangingPlaceShown() {
        self.locationManager.stopUpdatingLocation()
        self.currentLocationButton.isEnabled = true
        self.activityIndicator.stopAnimating()
        locationSearchView.isUserInteractionEnabled = true
    }
    
    
    //This function is called by changePlaceShown and is run right before acquiring new values for a new place.
    //It resets some values to create a clean slate for the next place to be shown.
    private func resetValuesForNewPlace() {
        photoDetailView.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: nil, place: nil)
        locationAPIService.generalLocalePlace?.photoArray.removeAll(keepingCapacity: false)
        locationAPIService.generalLocalePlace?.photoMetaDataArray.removeAll(keepingCapacity: false)
    }
    
    
    //Update the view model to display new place photos after a new place has been chosen
    private func loadNewPlacePhotos(completion: @escaping (_ result: Bool) ->()) {
        locationAPIService.setPhotosOfGeneralLocale(size: self.locationImageView.bounds.size, scale: self.locationImageView.window!.screen.scale) { (isImageSet) -> () in
            if (isImageSet) {
                guard let thisCurrentGeneralLocalePlace = self.locationAPIService.generalLocalePlace else {
                    print("Error - Current place is nil. Cannot set photos of the general locale.")
                    return
                }
                
                //If there are no photos and the user never wants to see default photos, hide location image and photo detail view
                if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos == .never) {
                    self.resetViewModelImageIndices(resetValue: nil)
                }
                    //Else reset image page control to the beginning
                else {
                    self.resetViewModelImageIndices(resetValue: 0)
                }
                completion(true)
            }
        }
    }
    
    
    //Get the weather forecast. Update the view model to display weather info when a new place has been chosen.
    func loadNewPlaceWeather(completion: @escaping (_ result: Bool) ->()) {
        guard let currentPlace = locationAPIService.currentPlace else {return}
        guard let currentGMSPlace = currentPlace.gmsPlace else {return}
        
        weatherAPIService.forecastDayDataPointArray.removeAll(keepingCapacity: false)
        
        weatherAPIService.setCurrentWeatherForecast(latitude: currentGMSPlace.coordinate.latitude, longitude: currentGMSPlace.coordinate.longitude) { (forecastRetrieved) -> () in
            if (forecastRetrieved) {
                self.currentWeatherView.viewModel?.updateForecast(newForecast: self.weatherAPIService.currentWeatherForecast)
                self.futureWeatherView.viewModel?.updateForecastDayDataPointArray(newForecastDayDataPointArray: self.weatherAPIService.forecastDayDataPointArray, newTimeZoneIdentifier: self.weatherAPIService.currentWeatherForecast?.timezone)
                
                completion(true)
            }
        }
    }
}
