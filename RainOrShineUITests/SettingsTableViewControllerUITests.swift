//
//  SettingsTableViewControllerUITests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

class SettingsTableViewControllerUITests: XCTestCase {
    
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Ensure the back button dismisses the Settings screen
    func testBackButtonDismissesSettings() {
        app.toolbars.buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Back"].tap()
        XCTAssertFalse(app.navigationBars["Settings"].exists, "Pressing the back button did not dismiss SettingsTableViewController.")
    }
    
    
    //Ensure the back button goes to WeatherViewController
    func testBackButtonGoesToWeatherViewController() {
        app.toolbars.buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Back"].tap()
        XCTAssertTrue(app.toolbars.buttons["Settings"].exists, "Pressing the back button did not go back to WeatherViewController.")
    }
}
