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
        super.tearDown()
    }
    
    
    //IMPORTANT
    //In order to run these tests correctly, you MUST simulate the location for Apple
    //Do this from the iOS Simulator by going to Debug -> Location -> Apple
    
    //Set the current exact place based on GPS signal and make sure that the returned address is correct
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
    
    
    //Set the general locale place based on GPS signal and make sure that the returned address is correct
    func testSetGeneralLocalePlace() {
        let setGeneralLocalePlaceExpectation = expectation(description: "setGeneralLocalePlace finds the gmsPlace and runs the callback closure")
        
        let locationAPIService: LocationAPIService = LocationAPIService()
        
        locationAPIService.setAPIKeys()
        
        locationAPIService.setCurrentExactPlace() { (isExactLocationFound, exactLocationPlace) -> () in
            if (isExactLocationFound) {
                locationAPIService.currentPlace = exactLocationPlace
            
                locationAPIService.setGeneralLocalePlace { (isGeneralLocationFound, generalLocationPlace) -> () in
                    if (isGeneralLocationFound) {
                        guard let formattedAddress = generalLocationPlace?.gmsPlace?.formattedAddress else {
                            XCTAssert(false, "The returned formatted address was nil.")
                            return
                        }
                        
                        XCTAssert(formattedAddress == "Cupertino, CA, USA", "The address returned is not the correct address for the general locale with latitude: 55.213448, longitude: 20.608194.  The address should be Cupertino, CA, USA")
                        setGeneralLocalePlaceExpectation.fulfill()
                    }
                }
            }
        }
        
        //Wait 5 seconds for the location to return until declaring failure
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    //Set photos of the general locale and make sure the photoArray populates with elements
    func testSetPhotosOfGeneralLocale() {
        var asserted: Bool = false
        
        let setGeneralLocalePhotosExpectation = expectation(description: "setGeneralLocalePhotos finds photos and populates the photoArray.")
        
        let locationAPIService: LocationAPIService = LocationAPIService()
        
        locationAPIService.setAPIKeys()
        
        locationAPIService.setCurrentExactPlace() { (isExactLocationFound, exactLocationPlace) -> () in
            if (isExactLocationFound) {
                locationAPIService.currentPlace = exactLocationPlace
                
                locationAPIService.setGeneralLocalePlace { (isGeneralLocationFound, generalLocationPlace) -> () in
                    if (isGeneralLocationFound) {
                        locationAPIService.generalLocalePlace = generalLocationPlace
                        
                        //Using a test image size of 500x500 and a test scale of 2.0
                        locationAPIService.setPhotosOfGeneralLocale(size: CGSize(width: 500, height: 500), scale: 2.0) { (isImageSet) -> () in
                            if (isImageSet) {
                                guard let thisCurrentGeneralLocalePlace = locationAPIService.generalLocalePlace else {
                                    XCTAssert(false, "The returned general locale place was nil.")
                                    return
                                }
                                
                                if (asserted == false) {
                                    print("ASSERTING TRUE>..")
                                    
                                    XCTAssertTrue(!thisCurrentGeneralLocalePlace.photoArray.isEmpty, "Photo array was not populated with any photos.")
                                    setGeneralLocalePhotosExpectation.fulfill()
                                    asserted = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Wait 7 seconds for the photos to return until declaring failure
        waitForExpectations(timeout: 7) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}




