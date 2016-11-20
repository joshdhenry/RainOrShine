
//
//  IconExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import ForecastIO

extension Icon {
    
    func getSkycon() -> Skycons? {
        switch self {
        case .clearDay:
            return Skycons.clearDay
        case .clearNight:
            return Skycons.clearNight
        case .cloudy:
            return Skycons.cloudy
        case .fog:
            return Skycons.fog
        case .partlyCloudyDay:
            return Skycons.partlyCloudyDay
        case .partlyCloudyNight:
            return Skycons.partlyCloudyNight
        case .rain:
            return Skycons.rain
        case .sleet:
            return Skycons.sleet
        case .snow:
            return Skycons.snow
        case .wind:
            return Skycons.wind
        }
    }
}
