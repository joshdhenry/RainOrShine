//
//  LocationAPIServiceTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/18/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest
import CoreLocation

@testable import RainOrShine

class LocationAPIServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    //IMPORTANT
    //In order to run this test correctly, you MUST simulate the location for apple
    //Do this from the iOS Simulator by going to Debug -> Location -> Apple
    func testSetCurrentExactPlace() {
        let setLocationExpectation = expectation(description: "setCurrentExactPlace finds the gmsPlace and runs the callback closure")
        
        let locationAPIService: LocationAPIService = LocationAPIService()

        locationAPIService.setAPIKeys()
        
        locationAPIService.setCurrentExactPlace() { (isLocationFound, locationPlace) -> () in
            if (isLocationFound) {
                print("Found the exact place...")

                guard let formattedAddress = locationPlace?.gmsPlace?.formattedAddress else {
                    XCTAssert(false, "The returned formatted address was nil.")
                    return
                }
                
                XCTAssert(formattedAddress == "1 Infinite Loop, Cupertino, CA 95014, USA", "The address returned is not the correct address for the location latitude: 55.213448, longitude: 20.608194.  The address should be 1 Infinite Loop, Cupertino, CA 95014, USA.")
                setLocationExpectation.fulfill()
            }
        }
        
        //Wait 5 seconds for the location to return until declaring failure
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    //TODO: -Finish test functions for LocationAPIService
    func testSetGeneralLocalePlace() {
        
    }
    
    
    func testSetPhotosOfGeneralLocale() {
        
    }
}




