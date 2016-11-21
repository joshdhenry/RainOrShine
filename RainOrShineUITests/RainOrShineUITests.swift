//
//  RainOrShineUITests.swift
//  RainOrShineUITests
//
//  Created by Josh Henry on 10/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class RainOrShineUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    //Tap the settings button and ensure that the SettingsViewController appears on the screen.
    func testSettingsButton() {
        let app = XCUIApplication()
        
        app.toolbars.buttons["Settings"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)
    }
    
    
    //TODO: -Finish writing this test
    func testGPSButton() {
        let gpsiconButton = XCUIApplication().toolbars.buttons["GPSIcon"]
        gpsiconButton.tap()
    }
    
    func testLocationImage() {
        //let setLocationExpectation = expectation(description: "setCurrentExactPlace finds the gmsPlace and runs the callback closure")
        
        let app = XCUIApplication()
        
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
