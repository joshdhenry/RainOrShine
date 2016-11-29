//
//  LocationViewModelTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class LocationViewModelTests: XCTestCase {
    
    let locationViewModel: LocationViewModel = LocationViewModel(place: nil)

    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Test the updatePlace method by calling it with an argument of a place with a test image.  If the value changes in the view model, the updatePlace works correctly
    func testupdateGeneralLocalePlace() {
        let newPlace: Place = Place()
        let testImage = UIImage(named: "TestImage")
        newPlace.photoArray.append(testImage)
        
        locationViewModel.updateGeneralLocalePlace(newPlace: newPlace)
        
        XCTAssertEqual(locationViewModel.currentGeneralLocalePlace.value?.photoArray[0], newPlace.photoArray[0], "locationViewModel.updatePlace did not correctly update locationViewModel.currentPlace.")
    }
    
    
    //Test the updatePlace method by calling it with an argument of a place with a test image.  If the value changes in the view model, the updatePlace works correctly
    func testupdateGeneralLocalePlaceWithNil() {
        locationViewModel.updateGeneralLocalePlace(newPlace: nil)
        
        guard let _ = locationViewModel.currentGeneralLocalePlace.value?.photoArray else {
            XCTAssert(true)
            return
        }
        
        XCTAssert(false, "locationViewModel.updatePlace did not correctly update locationViewModel.currentPlace when passing a nil value.")
    }
}
