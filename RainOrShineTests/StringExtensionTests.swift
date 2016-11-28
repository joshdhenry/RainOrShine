//
//  StringExtensionTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/27/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class StringExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testIntFromPlainEnglishValidString() {
        let validPlainEnglishNumberString: String = "15 Minutes"
        XCTAssertEqual(validPlainEnglishNumberString.intFromPlainEnglish, 15, "Converting a valid plain english number string to Int did not return the correct value.")
    }
    
    
    func testIntFromPlainEnglishInvalidString() {
        let invalidPlainEnglishNumberString: String = "something entirely wrong"
        XCTAssertEqual(invalidPlainEnglishNumberString.intFromPlainEnglish, 0, "Converting an invalid plain english number string to Int did not return the correct value (0).")
    }
}
