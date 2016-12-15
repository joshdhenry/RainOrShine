//
//  WeatherViewControllerExtensionCLLocationManagerDelegate.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/19/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import CoreLocation

//Handle all functions related to finding the user's current GPS position
extension WeatherViewController: CLLocationManagerDelegate {
    
    // MARK: - Methods
    
    //Set and configure the location manager
    internal func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    
    //Called every time a new gps signal is received
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {return}
        NSLog("--------------")
        NSLog("Location found - \(location.coordinate.latitude) \(location.coordinate.longitude)")
        NSLog("Accuracy - \(manager.location?.horizontalAccuracy)")
        //NSLog("Desired Accuracy - \(manager.desiredAccuracy)")
        NSLog("Age -\(manager.location?.timestamp.timeIntervalSinceNow)")
        
        //Sometimes the first coordinates received from the GPS might be inaccurate or cached locations from previous location locks. Filter those out.
        let locationAge: TimeInterval = -(location.timestamp.timeIntervalSinceNow)
        
        //Test the age of the location to make sure it is not cached
        guard (locationAge < 5.0) else {
            NSLog("Received cached location. Voiding this location and loading more until they are not cached...")
            return
        }
        
        //Less than 0 horizontalAccuracy means invalid reading
        guard (location.horizontalAccuracy >= 0) else {
            NSLog("Received invalid reading (horizontalAccuracy < 0). Voiding this location and loading more...")
            return
        }
        
        //It seems that 1414 is the constant the CLLocationManager gives if it has determined your location based on cell tower triangulation. If it has determined your location based on wifi, it gives a horizontal accuracy of 65m.
        guard (location.horizontalAccuracy <= 1414) else {
            NSLog("Received inaccurate reading (horizontalAccuracy > 1414). Voiding this location and loading more...")
            return
        }
        
        validGPSConsecutiveSignalsReceived += 1

        //One valid GPS reading in a row seems to be accurate enough for this app's purposes, but can be stepped up here to more.
        if (validGPSConsecutiveSignalsReceived == 1) {
            NSLog("FOUND AN ACCURATE GPS READING.  CALLING UPDATELOCATIONAPISERVICELOCATIONS()...")
            self.updateLocationAPIServiceLocations()
        }
    }
    
    
    //Handle location manager errors
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location manager error - \(error)")
    }
}
