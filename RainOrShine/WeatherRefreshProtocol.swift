//
//  WeatherRefreshProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/25/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

protocol WeatherRefreshDelegate {    
    func updateNeedsWeatherRefresh(needsWeatherRefresh: Bool)
}
