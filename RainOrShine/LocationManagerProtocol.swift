//
//  locationManagerProtocol.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/29/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManager {
    var location: CLLocation? {get}
}
