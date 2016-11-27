//
//  LocationSearchViewTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/19/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class LocationSearchViewTests: XCTestCase {
    
    var viewController: WeatherViewController!
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Test to make sure that viewController.displayLocationSearchBar adds the subview to the view
    func testLocationSearchBarAdded() {
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! WeatherViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        var searchBarFound: Bool = false
        
        for view in viewController.view.subviews {
            if (view.accessibilityIdentifier == "Location Search Bar") {
                searchBarFound = true
            }
        }
        
        XCTAssertTrue(searchBarFound, "viewController did not correctly add the location search bar to the view...")
    }
}
