//
//  SettingsDetailViewControllerUITests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/25/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

class SettingsDetailViewControllerUITests: XCTestCase {
    
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testTemperatureUnitsPopulate() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Temperature Unit"].tap()
        
        XCTAssert(app.tables.cells.count == 2, "Not all temperature units populated.")
    }
    
    
    func testUpdateWeatherEveryPopulate() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Update Weather Every"].tap()
        
        XCTAssert(app.tables.cells.count == 3, "Not all time options listed for Update Weather Every X Minutes.")
    }
    
    
    func UseDefaultPhotosPopulate() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Use Default Photos"].tap()
        
        XCTAssert(app.tables.cells.count == 3, "Not all options listed for Use Default Photos.")
    }
    
    
    func testChangePhotosEveryPopulate() {
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Change Photos Every"].tap()
        
        XCTAssert(app.tables.cells.count == 6, "Not all time options listed for Change Photos Every X Minutes.")
    }
}
