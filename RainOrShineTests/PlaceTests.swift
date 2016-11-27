//
//  PlaceTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/17/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class PlaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //IMPORTANT
    //In order to run these tests correctly, you MUST simulate the location for Apple
    //Do this from the iOS Simulator by going to Debug -> Location -> Apple
    
    func testGetGeneralLocaleString() {
        let getGeneralLocaleStringExpectation = expectation(description: "getGeneralLocaleString() runs on a place and returns the correct string.")
        
        let locationAPIService: LocationAPIService = LocationAPIService()
        
        locationAPIService.setAPIKeys()
        
        locationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound) {
                locationAPIService.currentPlace = locationPlace
                
                guard let thisCurrentPlace = locationAPIService.currentPlace else {
                    XCTAssert(false, "locationAPIService.currentPlace was nil.  Cannot get the general locale string.")
                    return
                }
                
                let generalLocaleString: String = thisCurrentPlace.getGeneralLocaleString()
                
                XCTAssert(generalLocaleString == "Cupertino+California+United+States", "The general locale string returned is not the correct one for the Apple location.  The address should be Cupertino+California+United+States.")
                getGeneralLocaleStringExpectation.fulfill()
            }
        }
        
        //Wait 5 seconds for the location to return until declaring failure
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
