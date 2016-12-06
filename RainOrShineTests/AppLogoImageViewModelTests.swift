//
//  AppLogoImageViewModelTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class AppLogoImageViewModelTests: XCTestCase {
        
    let appLogoImageViewModel: AppLogoImageViewModel = AppLogoImageViewModel(placeImageIndex: nil, place: nil)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Ensure that updatePlaceImageIndex() correctly updates the view model's currentPlaceImageIndex and currentGeneralLocalePlace
    func testUpdatePlaceImageIndex() {
        appLogoImageViewModel.updatePlaceImageIndex(newPlaceImageIndex: 321, place: Place())
        
        XCTAssert(appLogoImageViewModel.currentPlaceImageIndex.value == 321 &&
            appLogoImageViewModel.currentGeneralLocalePlace.value != nil,
                  "UpdatePlaceImageIndex() did not correctly update the place and/or the image index.")
    }
    
    
    func testUpdatePlaceImageIndexWithNil() {
        appLogoImageViewModel.updatePlaceImageIndex(newPlaceImageIndex: nil, place: nil)
        
        XCTAssert(appLogoImageViewModel.currentPlaceImageIndex.value == nil &&
            appLogoImageViewModel.currentGeneralLocalePlace.value == nil,
                  "UpdatePlaceImageIndex() did not correctly update the place and/or the image index when passed nil.")
    }
}
