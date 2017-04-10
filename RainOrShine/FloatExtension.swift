//
//  ForecastExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

extension Float {
    
    // MARK: - Computed variable
    var formattedTemperatureString: String {
        //If the number is between -0.5 and 0, we don't want it to appear as "-0°", so adjust it 
        //else remove any decimal places and append a degrees symbol
        return (self >= -0.5 && self < 0) ? "0°" : String(format: "%.0f", self) + "°"
    }
}
