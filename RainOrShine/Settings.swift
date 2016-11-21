//
//  Settings.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/20/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

struct Settings {
    let savedAppSettings = UserDefaults.standard
    
    enum UseDefaultPhotosSetting: String {
        case always = "always",
        whenNoPictures = "whenNoPictures",
        never = "never"
    }
    
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
}
