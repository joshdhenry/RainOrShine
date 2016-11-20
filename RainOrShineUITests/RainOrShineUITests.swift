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
}
