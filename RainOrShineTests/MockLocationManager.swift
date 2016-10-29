//
//  MockLocationManager.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/29/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import CoreLocation

class MockLocationManager: LocationManager {
    var location: CLLocation? = CLLocation(latitude: 55.213448, longitude: 20.608194)
}
