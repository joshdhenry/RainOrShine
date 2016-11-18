//
//  LocationImageView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class LocationImageView: UIImageView {

    // MARK: - Properties
    // MARK: View Model
    var viewModel: LocationImageViewModel? {
        didSet {
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let currentPlace: Place = LocationAPIService.currentPlace else {
                    //Place is nil.  App must be just starting
                    self.image = nil
                    return
                }
                
                if (!currentPlace.generalLocalePhotoArray.isEmpty) {
                    self.image = currentPlace.generalLocalePhotoArray[($0)!]
                }
                else {
                    //No images
                    self.image = nil
                }
            }
        }
    }
    
    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeViewModel()
    }
    
    // MARK: - Methods
    func initializeViewModel() {
        print("Initializing location image view model...")
        self.viewModel = LocationImageViewModel()
    }
}
