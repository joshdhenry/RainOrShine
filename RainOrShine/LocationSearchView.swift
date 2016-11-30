//
//  LocationSearchView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

class LocationSearchView: UIView {
    
    // MARK: - Properties
    public var resultsViewController: GMSAutocompleteResultsViewController?
    public var searchController: UISearchController?
    
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(withOrientation: UIDeviceOrientation, screenWidthAndHeight: CGSize) {
        var locationSearchViewFrame: CGRect = CGRect()
        
        if (withOrientation.isPortrait ||
           withOrientation.isFlat) {
            locationSearchViewFrame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.width, height: 45)
        }
        else if (withOrientation.isLandscape) {
            locationSearchViewFrame = CGRect(x: 0, y: 20, width: screenWidthAndHeight.height, height: 45)
        }
        super.init(frame: locationSearchViewFrame)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        
        let cityFilter: GMSAutocompleteFilter = GMSAutocompleteFilter()
        cityFilter.type = .city
        resultsViewController?.autocompleteFilter = cityFilter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.barTintColor = ColorScheme.lightGray

        self.addSubview((searchController?.searchBar)!)
        
        self.accessibilityIdentifier = "Location Search Bar"
        self.searchController?.searchBar.sizeToFit()
    }
}
