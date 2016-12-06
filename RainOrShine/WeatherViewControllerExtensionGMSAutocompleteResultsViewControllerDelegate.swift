//
//  WeatherViewControllerGMSAutocompleteResultsViewControllerDelegateExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/27/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import GooglePlaces
// Handle the user's selection..
extension WeatherViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    // MARK: - Methods
    //If the user selects a new city from the place search, display it's info and picture
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        self.locationSearchView.searchController?.isActive = false
        
        activityIndicator.startAnimating()
        
        makeSubViewsInvisible()
        
        let searchedPlace = Place(place: place)
        
        self.photoDetailView.viewModel?.updatePlace(newPlace: searchedPlace)

        locationAPIService.currentPlace = searchedPlace

        //Set the general locale of the place (better for pictures and displaying user's location)
        locationAPIService.setGeneralLocalePlace() { (isGeneralLocaleFound, generalLocalePlace) -> () in
            if (isGeneralLocaleFound) {
                self.locationView.viewModel?.updateGeneralLocalePlace(newPlace: generalLocalePlace)
                
                self.locationAPIService.generalLocalePlace = generalLocalePlace
                
                self.changePlaceShown()
            }
        }
    }
    
    
    //If places autocomplete fails, print an error.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    
    // Turn the network activity indicator on when pulling location predictions.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    
    // Turn the network activity indicator off when done pulling location predictions.
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
