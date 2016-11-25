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
        case always = "always",
        whenNoPictures = "whenNoPictures",
        never = "never"
    }
    
    enum TemperatureUnitSetting: String {
        case fahrenheit = "fahrenheit",
        celcius = "celcius"
    }
    
    enum UpdateWeatherIntervalSetting: String {
        case fifteen = "15",
        thirty = "30",
        sixty = "60"
    }
    
    enum ChangePhotoIntervalSetting: String {
        case one = "1",
        three = "3",
        five = "5",
        ten = "10",
        thirty = "30",
        never = "0"
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
