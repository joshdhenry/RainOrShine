//
//  WeatherViewControllerExtensionUISearchBarDelegate.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/19/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

extension WeatherViewController: UISearchBarDelegate {
    // MARK: - Methods
    //Initialize and configure the Google Places search controllers
    internal func createLocationSearchElements() {
        locationSearchView = LocationSearchView(withOrientation: UIDevice.current.orientation, screenWidthAndHeight: screenWidthAndHeight)
        locationSearchView.resultsViewController?.delegate = self
        locationSearchView.searchController?.searchBar.delegate = self
        self.view.addSubview(locationSearchView)
        
        locationSearchView.searchController?.hidesNavigationBarDuringPresentation = false
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    
    //Resize the location search view with the current screen dimensions
    internal func resizeLocationSearchView(orientationAfterRotation: UIDeviceOrientation) {
        //print("In resizeLocationSearchView...")
        
        if orientationAfterRotation.isPortrait {
            //Switching to portrait
            showStatusBar(enabled: true)
            locationSearchView.frame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45)
            locationSearchView.searchController?.view.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.width, height: screenWidthAndHeight.height)
        }
        else if orientationAfterRotation.isLandscape {
            //Switching to landscape
            showStatusBar(enabled: false)
            locationSearchView.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: 45)
        }
        locationSearchView.searchController?.searchBar.sizeToFit()
    }
}
