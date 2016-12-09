//
//  LocationLoaderProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

//Handle duties related to loading in a new location
protocol LocationLoader {
    
    // MARK: - Required methods
    func startFindingCurrentLocation(alertsEnabled: Bool)
    func updateLocationAPIServiceLocations()
    func changePlaceShown()
    func loadNewPlaceWeather(completion: @escaping (_ result: Bool) ->())
}
