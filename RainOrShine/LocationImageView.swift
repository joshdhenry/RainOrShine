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
                guard let _ = self.viewModel?.currentGeneralLocalePlace.value else {
                    //Place is nil.  App must be just starting
                    self.image = nil
                    return
                }

                guard let imageIndex = $0 else {
                    //No images
                    self.image = nil
                    return
                }

                if (!(self.viewModel?.currentGeneralLocalePlace.value?.photoArray.isEmpty)!) {
                    self.image = self.viewModel?.currentGeneralLocalePlace.value?.photoArray[imageIndex]
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
