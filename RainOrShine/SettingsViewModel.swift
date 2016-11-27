//
//  SettingsViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/27/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct SettingsViewModel {
    // MARK: - Properties
    let currentTemperatureUnit: Observable<Settings.TemperatureUnitSetting?>
    let currentUpdateWeatherInterval: Observable<Settings.UpdateWeatherIntervalSetting?>
    let currentUseDefaultPhotos: Observable<Settings.UseDefaultPhotosSetting?>
    let currentChangePhotoInterval: Observable<Settings.ChangePhotoIntervalSetting?>
    let currentNightStandModeOn: Observable<Bool?>
    
    
    // MARK: - Initializer
    init(temperatureUnit: Settings.TemperatureUnitSetting?,
         updateWeatherInterval: Settings.UpdateWeatherIntervalSetting?,
         useDefaultPhotos: Settings.UseDefaultPhotosSetting?,
         changePhotoInterval: Settings.ChangePhotoIntervalSetting?,
         nightStandModeOn: Bool?) {
        currentTemperatureUnit = Observable(temperatureUnit)
        currentUpdateWeatherInterval = Observable(updateWeatherInterval)
        currentUseDefaultPhotos = Observable(useDefaultPhotos)
        currentChangePhotoInterval = Observable(changePhotoInterval)
        currentNightStandModeOn = Observable(nightStandModeOn)
    }
    
    
    // MARK: - Methods
    func updateTemperatureUnit(newTemperatureUnit: Settings.TemperatureUnitSetting?) {
        //print("In func updateTemperatureUnit...")
        currentTemperatureUnit.value = newTemperatureUnit
    }
    
    
    func updateUpdateWeatherInterval(newUpdateWeatherInterval: Settings.UpdateWeatherIntervalSetting?) {
        currentUpdateWeatherInterval.value = newUpdateWeatherInterval
    }
    
    
    func updateUseDefaultPhotos(newUseDefaultPhotos: Settings.UseDefaultPhotosSetting?) {
        currentUseDefaultPhotos.value = newUseDefaultPhotos
    }
    
    
    func updateChangePhotoInterval(newChangePhotoInterval: Settings.ChangePhotoIntervalSetting?) {
        currentChangePhotoInterval.value = newChangePhotoInterval
    }
    
    
    func updateNightStandModeOn(newNightStandModeOn: Bool?) {
        currentNightStandModeOn.value = newNightStandModeOn
    }
}
