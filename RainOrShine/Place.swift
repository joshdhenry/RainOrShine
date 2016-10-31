//
//  Place.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/30/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import GooglePlaces

class Place {
    
    var gmsPlace: GMSPlace?
    var firstGeneralLocalePhotoMetaData: GMSPlacePhotoMetadata?
    var firstGeneralLocalePhoto: UIImage?
    
    //This method resets all current place variables to nil
    public func resetPlace() {
        self.gmsPlace = nil
        
        self.firstGeneralLocalePhotoMetaData = nil
        self.firstGeneralLocalePhoto = nil
    }
}
