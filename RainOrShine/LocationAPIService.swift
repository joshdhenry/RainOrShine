//
//  LocationAPIService.swift
//  RainOrShine
//
//  Created by Josh Henry on 10/28/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import GooglePlaces

class LocationAPIService {
    var placesClient: GMSPlacesClient? = GMSPlacesClient.shared()
    var currentPlace: GMSPlace?
    
    var placeFindComplete: Bool = false
    
    func getCurrentLocation(completion: @escaping (_ result: Bool)->()) {
        placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                let place = placeLikelihoods.likelihoods.first?.place
                print("HEY \(place?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n"))")
                self.currentPlace = place
                print("set the place now going back to VC...")
                self.placeFindComplete = true
                
                completion(true)
                
                return
            }
        })
        if self.placeFindComplete == false {
            print("placefindcomplete is false...")
            completion(false)
        }
        print("RETURNING...")
    }
}
