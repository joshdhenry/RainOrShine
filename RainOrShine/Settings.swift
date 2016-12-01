//
//  Settings.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/20/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct Settings {
    // MARK: - Properties
    let savedAppSettings = UserDefaults.standard
    
    enum UseDefaultPhotosSetting: String {
        case always = "Always",
        whenNoPictures = "When No  Photos Available",
        never = "Never"
    }
    
    enum TemperatureUnitSetting: String {
        case fahrenheit = "Fahrenheit",
        celcius = "Celcius"
    }
    
    enum UpdateWeatherIntervalSetting: String {
        case fifteen = "15 Minutes",
        thirty = "30 Minutes",
        sixty = "60 Minutes"
    }
    
    enum ChangePhotoIntervalSetting: String {
        case one = "1 Minute",
        three = "3 Minutes",
        five = "5 Minutes",
        ten = "10 Minutes",
        thirty = "30 Minutes",
        never = "Never"
    }
    
    
    // MARK: Computed Properties
    var useDefaultPhotos: UseDefaultPhotosSetting {
        get {
            let appSettingRawValue: String = savedAppSettings.object(forKey: "useDefaultPhotos") as? String ?? UseDefaultPhotosSetting.whenNoPictures.rawValue
            let useDefaultPhotosEnumValue: UseDefaultPhotosSetting = UseDefaultPhotosSetting(rawValue: appSettingRawValue) ?? UseDefaultPhotosSetting.whenNoPictures
            return useDefaultPhotosEnumValue
        }
        set {
            savedAppSettings.set(newValue.rawValue, forKey: "useDefaultPhotos")
        }
    }
    
    
    
    var temperatureUnit: TemperatureUnitSetting {
        get {
            let appSettingRawValue: String = savedAppSettings.object(forKey: "temperatureUnit") as? String ?? TemperatureUnitSetting.fahrenheit.rawValue
            let temperatureUnitEnumValue: TemperatureUnitSetting = TemperatureUnitSetting(rawValue: appSettingRawValue) ?? TemperatureUnitSetting.fahrenheit
            return temperatureUnitEnumValue
        }
        set {
            savedAppSettings.set(newValue.rawValue, forKey: "temperatureUnit")
        }
    }
    
    
    var updateWeatherInterval: UpdateWeatherIntervalSetting {
        get {
            let appSettingRawValue: String = savedAppSettings.object(forKey: "updateWeatherInterval") as? String ?? UpdateWeatherIntervalSetting.thirty.rawValue
            let updateWeatherIntervalEnumValue: UpdateWeatherIntervalSetting = UpdateWeatherIntervalSetting(rawValue: appSettingRawValue) ?? UpdateWeatherIntervalSetting.thirty
            return updateWeatherIntervalEnumValue
        }
        set {
            savedAppSettings.set(newValue.rawValue, forKey: "updateWeatherInterval")
        }
    }
    
    
    var changePhotoInterval: ChangePhotoIntervalSetting {
        get {
            let appSettingRawValue: String = savedAppSettings.object(forKey: "changePhotoInterval") as? String ?? ChangePhotoIntervalSetting.three.rawValue
            let updateWeatherIntervalEnumValue: ChangePhotoIntervalSetting = ChangePhotoIntervalSetting(rawValue: appSettingRawValue) ?? ChangePhotoIntervalSetting.three
            return updateWeatherIntervalEnumValue
        }
        set {
            savedAppSettings.set(newValue.rawValue, forKey: "changePhotoInterval")
        }
    }
    
    
    var nightStandModeOn: Bool {
        get {
            let nightStandModeAppSetting: Bool = savedAppSettings.object(forKey: "nightStandModeOn") as? Bool ?? false
            return nightStandModeAppSetting
        }
        set {
            savedAppSettings.set(newValue, forKey: "nightStandModeOn")
        }
    }
    
    
    var removeAdsPurchased: Bool {
        get {
            let removeAdsPurchasedAppSetting: Bool = savedAppSettings.object(forKey: "removeAdsPurchased") as? Bool ?? false
            return removeAdsPurchasedAppSetting
        }
        set {
            savedAppSettings.set(newValue, forKey: "removeAdsPurchased")
        }
    }
}
