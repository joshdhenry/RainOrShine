//
//  SettingsTest.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/26/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class SettingsTest: XCTestCase {
    
    var settings = Settings()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    //Set the useDefaultPhotos setting, then get the useDefaultPhotosSetting and make sure that it is the same
    func testUseDefaultPhotosGetterAndSetter() {
        settings.useDefaultPhotos = .never
        XCTAssertEqual(settings.useDefaultPhotos, Settings.UseDefaultPhotosSetting.never, "Settings.useDefaultPhotos is not getting and/or setting correctly.")
    }
    
    
    //Set the changePhotoInterval setting, then get the changePhotoInterval and make sure that it is the same
    func testChangePhotoIntervalGetterAndSetter() {
        settings.changePhotoInterval = .never
        XCTAssertEqual(settings.changePhotoInterval, Settings.ChangePhotoIntervalSetting.never, "Settings.changePhotoInterval is not getting and/or setting correctly.")
    }
    
    
    //Set the nightStandMode setting, then get the nightStandMode and make sure that it is the same
    func testNightStandModeGetterAndSetter() {
        settings.nightStandModeOn = true
        XCTAssertTrue(settings.nightStandModeOn, "Settings.nightStandModeOn is not getting and/or setting correctly.")
    }
    
    
    //Set the removeAdsPurchased setting, then get the removeAdsPurchased and make sure that it is the same
    func testRemoveAdsPurchasedGetterAndSetter() {
        settings.removeAdsPurchased = true
        XCTAssertTrue(settings.removeAdsPurchased, "Settings.removeAdsPurchased is not getting and/or setting correctly.")
    }
    
}
