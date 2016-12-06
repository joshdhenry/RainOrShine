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
        locationSearchView.searchController?.hidesNavigationBarDuringPresentation = false
        self.view.addSubview(locationSearchView)
        
        //When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
    
    
    //Resize the location search view with the current screen dimensions
    internal func resizeLocationSearchView(orientationAfterRotation: UIDeviceOrientation) {
        let locationSearchViewHeight: CGFloat = 45
        let statusBarHeight: CGFloat = 20
        
        if orientationAfterRotation.isPortrait {
            //Switching to portrait.. Account for the status bar (height: 20 px)
            showStatusBar(enabled: true)
            locationSearchView.frame = CGRect(x: 0, y: statusBarHeight, width: screenWidthAndHeight.width, height: locationSearchViewHeight)
            locationSearchView.searchController?.view.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.width, height: screenWidthAndHeight.height)
        }
        else if orientationAfterRotation.isLandscape {
            //Switching to landscape (no status bar showing)
            showStatusBar(enabled: false)
            locationSearchView.frame = CGRect(x: 0, y: 0, width: screenWidthAndHeight.height, height: locationSearchViewHeight)
        }
        locationSearchView.searchController?.searchBar.sizeToFit()
    }
    
    
    //If the user is searching, disable rotation until finished
    internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        Rotation.allowed = false
    }
    
    
    //If the user is done searching, re-enable screen rotation
    internal func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        Rotation.allowed = true
    }
}
