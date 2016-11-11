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
        
        //let specificityLevelArray: [[String] = [1, ["locality", "administrative_area_level_3", "administrative_area_level_2"]]
        
        /*var dict: [Int: [String]] = [1: ["natural_feature"],
                                     1: ["locality", "administrative_area_level_3"],
                                     2: ["locality", "administrative_area_level_3"],
                                     3: ["locality", "administrative_area_level_3", "administrative_area_level_2"],
                                     4: ["locality", "administrative_area_level_3", "administrative_area_level_2", "administrative_area_level_1"]]*/
        //print("DICT")
        //print(dict[1])
        //let dict1Text = dict[1]
        
        var queryString: String = ""
        var isFirstItemInQueryString: Bool = true
        var cityNameAlreadyFound: Bool = false
        var naturalFeatureName: String?
        
        for addressComponent in (self.gmsPlace?.addressComponents)! {
            print(addressComponent.name)
            print(addressComponent.type)
            print("-----")
            
            switch (addressComponent.type) {
            //Prefer city, then county, then state, etc.
            case "locality", "administrative_area_level_3", "administrative_area_level_2":
                if (cityNameAlreadyFound == false) {
                    
                    if (isFirstItemInQueryString) {
                        queryString += addressComponent.name
                        isFirstItemInQueryString = false
                    }
                    else {
                        queryString += "+" + addressComponent.name
                    }
                    
                    cityNameAlreadyFound = true
                }
            case "administrative_area_level_1", "country":
                if (isFirstItemInQueryString) {
                    queryString += addressComponent.name
                    isFirstItemInQueryString = false
                }
                else {
                    queryString += "+" + addressComponent.name
                }
            case "natural_feature":
                naturalFeatureName = addressComponent.name
            default:
                break
            }
        }
        
        //If we don't get any city, state, country name, but we DO have a natural feature, make the query string the natural feature name.  Doesn't always return an image but increases the chances.
        if (queryString == "" &&
            naturalFeatureName != nil) {
            queryString += naturalFeatureName!
        }
        
        print("QUERY IS \(queryString)")
        
        //Replace any spaces in the URL with "+"
        queryString = queryString.replacingOccurrences(of: " ", with: "+")
        
        return queryString
    }
    
}
