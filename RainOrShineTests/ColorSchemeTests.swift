//
//  ColorSchemeTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/19/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class ColorSchemeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //Test the color scheme structs computed var by getting the light gray color and assuring it returns the correct UIColor
    func testColorSchemeComputedVar() {
        let lightGrayColor = ColorScheme.lightGray
        
        XCTAssertTrue(lightGrayColor == UIColor(netHex: 0xf9f9f9), "ColorScheme's computed color vars are not returning the correct value...")
    }
    
}
