//
//  SettingsDetailViewControllerUITests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/25/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

class SettingsDetailViewControllerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testTemperatureUnitsPopulate() {
        let app = XCUIApplication()
        
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Temperature Unit"].tap()
        XCTAssert(app.tables.cells.staticTexts["Celcius"].exists, "Not all temperature units populated.  Celcius was not found.")
    }
    
    //I'm having a hard time implementing this.  Google turns up very little.  There is no accessibility info attached to the checkmarks, so I can't test that way.
    /*func testTemperatureUnitCheckmark() {
        let app = XCUIApplication()
        
        app.toolbars.buttons["Settings"].tap()
        app.tables.cells.staticTexts["Temperature Unit"].tap()
        
        app.tables.cells.buttons
        
        
        XCTAssert(app.tables.cells.staticTexts["Celcius"].exists)
    }*/
    
    func testUpdateWeatherEveryCheckmark() {
        
    }
    
    
    func testUseDefaultPhotosCheckmark() {
        /*XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        app.toolbars.buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Use Default Photos"].tap()
        tablesQuery.staticTexts["When No Location Photos Available"].tap()
        app.navigationBars["Use Default Photos"].buttons["Settings"].tap()
        app.navigationBars["Settings"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()*/
        
    }
    
    
    func testChangePhotosEveryCheckmark() {
        
    }
    
    
    func testOnlyOneCheckmark() {
        
    }
    
}
