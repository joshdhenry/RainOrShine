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
    public var resultsViewController: GMSAutocompleteResultsViewController?
    public var searchController: UISearchController?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        
        let cityFilter: GMSAutocompleteFilter = GMSAutocompleteFilter()
        cityFilter.type = .city
        resultsViewController?.autocompleteFilter = cityFilter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.barTintColor = UIColor(netHex: ColorScheme.lightGray)
        //searchController?.searchBar.isTranslucent = true

        self.addSubview((searchController?.searchBar)!)
        
        self.accessibilityIdentifier = "Location Search Bar"
        self.searchController?.searchBar.sizeToFit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
