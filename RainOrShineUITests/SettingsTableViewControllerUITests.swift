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

    
    func testTemperatureUnitCellSubtitleChanges() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Temperature Unit"].tap()
        app.tables.cells.staticTexts["Celcius"].tap()
        app.navigationBars["Temperature Unit"].buttons["Settings"].tap()
        XCTAssert(app.tables.cells.staticTexts["Celcius"].exists)
    }
    
    
    func testUpdateWeatherIntervalCellSubtitleChanges() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Update Weather Every"].tap()
        app.tables.cells.staticTexts["60 Minutes"].tap()
        app.navigationBars["Update Weather Every"].buttons["Settings"].tap()
        XCTAssert(app.tables.cells.staticTexts["60 Minutes"].exists)
    }
    
    
    func testUseDefaultPhotosCellSubtitleChanges() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Use Default Photos"].tap()
        app.tables.cells.staticTexts["Always"].tap()
        app.navigationBars["Use Default Photos"].buttons["Settings"].tap()
        XCTAssert(app.tables.cells.staticTexts["Always"].exists)
    }
    
    
    func testChangePhotoIntervalCellSubtitleChanges() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Change Photos Every"].tap()
        app.tables.cells.staticTexts["10 Minutes"].tap()
        app.navigationBars["Change Photo Every"].buttons["Settings"].tap()
        XCTAssert(app.tables.cells.staticTexts["10 Minutes"].exists)
    }
}
