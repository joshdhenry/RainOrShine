//
//  LocationImageViewModelTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class LocationImageViewModelTests: XCTestCase {
    
    let locationImageViewModel: LocationImageViewModel = LocationImageViewModel(placeImageIndex: nil, place: nil)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Ensure that updatePlaceImageIndex() correctly updates the view model's currentPlaceImageIndex and currentGeneralLocalePlace
    func testUpdatePlaceImageIndex() {
        locationImageViewModel.updatePlaceImageIndex(newPlaceImageIndex: 321, place: Place())
        
        XCTAssert(locationImageViewModel.currentPlaceImageIndex.value == 321 &&
                  locationImageViewModel.currentGeneralLocalePlace.value != nil,
                  "UpdatePlaceImageIndex() did not correctly update the place and/or the image index.")
    }
    
    
    func testUpdatePlaceImageIndexWithNil() {
        locationImageViewModel.updatePlaceImageIndex(newPlaceImageIndex: nil, place: nil)
        
        XCTAssert(locationImageViewModel.currentPlaceImageIndex.value == nil &&
            locationImageViewModel.currentGeneralLocalePlace.value == nil,
                  "UpdatePlaceImageIndex() did not correctly update the place and/or the image index when passed nil.")
    }
}
