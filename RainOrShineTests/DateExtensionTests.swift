//
//  DateExtensionTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class DateExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Testing for November 26, 2016.  The string returned should be "Sat"
    func testAbbreviatedDayString() {
        var aDateComponents = DateComponents()
        aDateComponents.year = 2016
        aDateComponents.month = 11
        aDateComponents.day = 26
        
        let aCalendar = Calendar.current
        
        let aDate = aCalendar.date(from: aDateComponents)!
        XCTAssert(aDate.getAbbreviatedDayString(timeZoneIdentifier: "GMT") == "Sat", "The abbreviated day name is not correct.")
    }
}
