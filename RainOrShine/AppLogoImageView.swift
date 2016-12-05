//
//  AppLogoImageView.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/4/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

class AppLogoImageView: UIImageView {
    
    let currentSettings = Settings()
    
    // MARK: View Model
    var viewModel: AppLogoImageViewModel? {
        didSet {
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                let appLogoImage: UIImage = UIImage(named: "AppLogo")!
                
                guard let thisCurrentGeneralLocalePlace = self.viewModel?.currentGeneralLocalePlace.value else {
                    //Place is nil.  App must be just starting
                    self.isHidden = false
                    return
                }
                
                guard let imageIndex = $0 else {
                    //Nil currentPlaceImageIndex. No images.
                    self.isHidden = false
                    return
                }
                
                if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos != .always) {
                    //Place is not nil and has images
                    self.isHidden = true
                }
                else if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos == .always) {
                    //Use the default photos array
                    self.isHidden = true
                }
                else if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos != .never){
                    //Use the default photos array
                    self.isHidden = true
                }
                else if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    self.currentSettings.useDefaultPhotos == .never) {
                    
                    self.isHidden = false
                }
            }
        }
    }
    
    
    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
