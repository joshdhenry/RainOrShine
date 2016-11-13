//
//  LocationImageViewModel.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

class LocationImageViewModel {
    let currentPlaceImageIndex: Observable<Int?>
    
    
    init() {
        currentPlaceImageIndex = Observable(LocationAPIService.currentPlaceImageIndex)
    }
    
    
    func updatePlaceImageIndex(newPlaceImageIndex: Int?) {
        //print("In func updatePlaceImageIndex...")
        currentPlaceImageIndex.value = newPlaceImageIndex
    }
}
