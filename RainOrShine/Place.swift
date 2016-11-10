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
    
    public var gmsPlace: GMSPlace?
    public var generalLocalePhotoMetaDataArray: [GMSPlacePhotoMetadata?] = [GMSPlacePhotoMetadata?]()
    public var generalLocalePhotoArray: [UIImage?] = [UIImage?]()
    
    init() {}
    
    init(place: GMSPlace?) {
        self.gmsPlace = place
    }
    
    
    //This method builds a string of the general locality of the place, which will be used to query a photo of the general locale
    public func getGeneralLocaleString() -> String {
        //print("In function setGeneralLocaleString... (#1)")
        
        var queryString: String = ""
        
        for addressComponent in (LocationAPIService.currentPlace?.gmsPlace?.addressComponents)! {
            switch (addressComponent.type) {
                //case "sublocality_level_1":
            //    queryString += thisType.name
            case "locality":
                queryString += addressComponent.name
            case "administrative_area_level_1":
                queryString += "+" + addressComponent.name
            case "country":
                queryString += "+" + addressComponent.name
            default:
                break
            }
        }
        
        //Replace any spaces in the URL with "+"
        queryString = queryString.replacingOccurrences(of: " ", with: "+")
        
        return queryString
    }
}
