//
//  SettingsViewModelTests.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import XCTest

@testable import RainOrShine

class SettingsViewModelTests: XCTestCase {
    
    let settingsViewModel: SettingsViewModel = SettingsViewModel(temperatureUnit: Settings.TemperatureUnitSetting.fahrenheit, updateWeatherInterval: Settings.UpdateWeatherIntervalSetting.thirty, useDefaultPhotos: Settings.UseDefaultPhotosSetting.whenNoPictures, changePhotoInterval: Settings.ChangePhotoIntervalSetting.three, nightStandModeOn: false)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdateTemperatureUnit() {
        settingsViewModel.updateTemperatureUnit(newTemperatureUnit: Settings.TemperatureUnitSetting.celcius)
        XCTAssert(settingsViewModel.currentTemperatureUnit.value == Settings.TemperatureUnitSetting.celcius, "SettingsViewModel.updateTemperatureUnit did not correctly update  SettingsViewModel.currentTemperatureUnit.")
    }
    
    
    func testUpdateWeatherInterval() {
        settingsViewModel.updateUpdateWeatherInterval(newUpdateWeatherInterval: Settings.UpdateWeatherIntervalSetting.fifteen)
        XCTAssert(settingsViewModel.currentUpdateWeatherInterval.value == Settings.UpdateWeatherIntervalSetting.fifteen, "SettingsViewModel.updateWeatherInterval did not correctly update SettingsViewModel.currentUpdateWeatherInterval.")
    }
    
    
    func testUpdateUseDefaultPhotos() {
        settingsViewModel.updateUseDefaultPhotos(newUseDefaultPhotos: Settings.UseDefaultPhotosSetting.never)
        XCTAssert(settingsViewModel.currentUseDefaultPhotos.value == Settings.UseDefaultPhotosSetting.never, "SettingsViewModel.updateUseDefaultPhotos did not correctly update SettingsViewModel.currentUseDefaultPhotos.")
    }
    
    
    func testUpdateChangePhotoInterval() {
        settingsViewModel.updateChangePhotoInterval(newChangePhotoInterval: Settings.ChangePhotoIntervalSetting.one)
        XCTAssert(settingsViewModel.currentChangePhotoInterval.value == Settings.ChangePhotoIntervalSetting.one, "SettingsViewModel.updateChangePhotoInterval did not correctly update SettingsViewModel.currentChangePhotoInterval.")
    }
    
    
    func testUpdateNightStandModeOn() {
        settingsViewModel.updateNightStandModeOn(newNightStandModeOn: true)
        XCTAssertTrue(settingsViewModel.currentNightStandModeOn.value!, "SettingsViewModel.updateNightStandModeOn did not correctly update SettingsViewModel.currentNightStandModeOn.")
    }
}
