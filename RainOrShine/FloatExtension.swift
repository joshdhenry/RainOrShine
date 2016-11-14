//
//  ForecastExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

extension Float {
    
    var formattedTemperatureString: String {
        return String(format: "%.0f", self) + "°"
    }
}
