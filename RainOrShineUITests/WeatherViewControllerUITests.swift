//
//  WeatherViewControllerUITests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class WeatherViewControllerUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Tap the settings button and ensure that the SettingsViewController appears on the screen.
    func testSettingsButton() {
        app.toolbars.buttons["Settings"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)
    }
    
    
    //TODO: -Finish writing this test
    func testGPSButton() {
        app.toolbars.buttons["GPSIcon"].tap()
    }
    
    
    func testLocationImage() {
        //let setLocationExpectation = expectation(description: "setCurrentExactPlace finds the gmsPlace and runs the callback closure")
        
        let gpsiconButton = app.toolbars.buttons["GPSIcon"]
        gpsiconButton.tap()
        
        //sleep(5)
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        print("ID IS")
        print(app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.identifier)
        
        //app.images.containing(.image, identifier: "Location Image")
        
        
        
        
        
        
        //print("HEY \(app.images[0])")
        /*for view in viewController.view.subviews {
         if (view.accessibilityIdentifier == "Location Search Bar") {
         searchBarFound = true
         }
         }
         
         XCTAssert(formattedAddress == "1 Infinite Loop, Cupertino, CA 95014, USA", "The address returned is not the correct address for the location latitude: 55.213448, longitude: 20.608194.  The address should be 1 Infinite Loop, Cupertino, CA 95014, USA.")
         setLocationExpectation.fulfill()
         
         //Wait 5 seconds for the location to return until declaring failure
         waitForExpectations(timeout: 5) { error in
         if let error = error {
         XCTFail("waitForExpectationsWithTimeout errored: \(error)")
         }
         }*/
    }

}
