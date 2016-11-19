//
//  LocationImageView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class LocationImageView: UIImageView {
    
    // MARK: View Model
    var viewModel: LocationImageViewModel? {
        didSet {
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let thisCurrentPlace = self.viewModel?.currentPlace.value else {
                    //Place is nil.  App must be just starting
                    self.image = nil
                    return
                }
                
                guard let imageIndex = $0 else {
                    //No images
                    self.image = nil
                    return
                }
                
                if (!thisCurrentPlace.generalLocalePhotoArray.isEmpty) {
                    self.image = thisCurrentPlace.generalLocalePhotoArray[imageIndex]
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
    }
}
