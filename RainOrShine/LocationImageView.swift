//
//  LocationImageView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/13/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class LocationImageView: UIImageView {

    let currentSettings = Settings()
    
    // MARK: View Model
    var viewModel: LocationImageViewModel? {
        didSet {
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let thisCurrentGeneralLocalePlace = self.viewModel?.currentGeneralLocalePlace.value else {
                    //Place is nil.  App must be just starting
                    self.image = nil
                    return
                }

                guard let imageIndex = $0 else {
                    //Nil currentPlaceImageIndex. No images.
                    self.image = nil
                    return
                }

                if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos != .always) {
                    //Place is not nil and has images
                    self.image = self.viewModel?.currentGeneralLocalePlace.value?.photoArray[imageIndex]
                }
                else if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos == .always) {
                    //Use the default photos array
                    self.image = UIImage(named: String(imageIndex))
                }
                else if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos != .never){
                    //Use the default photos array
                    self.image = UIImage(named: String(imageIndex))
                }
                else if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos == .never) {
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
