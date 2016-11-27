//
//  FloatExtensionTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class FloatExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Ensure that a temperature gets formatted correctly
    func testFormattedTemperatureString() {
        let aTemperature: Float = 103.4567
        XCTAssert(aTemperature.formattedTemperatureString == "103°", "Temperature was not formatted into a string correctly.")
    }
    
}
