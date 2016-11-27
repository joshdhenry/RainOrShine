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
    
    
    //Ensure the screen and toolbar are still showing when the GPS button is tapped.
    func testGPSButton() {
        app.toolbars.buttons["GPSIcon"].tap()
        XCTAssert(app.toolbars.buttons["Settings"].exists)
    }
}
