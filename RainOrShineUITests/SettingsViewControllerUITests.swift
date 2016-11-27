//
//  SettingsViewControllerUITests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

class SettingsViewControllerUITests: XCTestCase {
    
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Ensure the back button dismisses the Settings screen
    func testBackButtonDismissesSettings() {
        app.toolbars.buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Back"].tap()
        XCTAssertFalse(app.navigationBars["Settings"].exists, "Pressing the back button did not dismiss SettingsViewController.")
    }
    
    
    //Ensure the back button goes to WeatherViewController
    func testBackButtonGoesToWeatherViewController() {
        app.toolbars.buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Back"].tap()
        XCTAssertTrue(app.toolbars.buttons["Settings"].exists, "Pressing the back button did not go back to WeatherViewController.")
    }
}
