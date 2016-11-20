//
//  WeatherViewControllerExtensionCLLocationManagerDelegate.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/19/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import CoreLocation

extension WeatherViewController: CLLocationManagerDelegate {
    //Set and configure the location manager
    internal func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    
    //Called every time a new gps signal is received
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        //Sometimes the first coordinates received from the GPS might be inaccurate or cached locations from previous location locks.
        //Wait for 5 GPS signals to be received before we have a semi reliable tracking.
        //ALSO, I NEED TO CACHE THE LAST FIVE LOCATIONS ACTUALLY USED.  MAKE SURE THE SIGNAL IS NOT REPORTING A PREVIOUS TRACKING AND IS GIVING FRESH, ACCURATE RESULTS
        gpsConsecutiveSignalsReceived += 1
        //print("gpsConsecutiveSignalsReceived is \(gpsConsecutiveSignalsReceived)")
        if gpsConsecutiveSignalsReceived == 5 {
            self.updateLocation()
        }
    }
    
    
    //Handle location manager errors
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error - \(error)")
    }
}
