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
    
    
    func getCurrentLocation(completion: @escaping (_ result: Bool)->()) {
        var placeFindComplete: Bool = false
        
        placesClient?.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                completion(true)
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                let place = placeLikelihoods.likelihoods.first?.place
                self.currentPlace = place
                placeFindComplete = true
                completion(true)
            }
        })
        if placeFindComplete == false {
            completion(false)
        }
    }
}
