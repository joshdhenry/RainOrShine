//
//  WeatherViewControllerExtensionAdDisplayer.swift
//  RainOrShine
//
//  Created by Josh Henry on 12/8/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

extension WeatherViewController: AdDisplayer {
    
    // MARK: Methods
    
    //Display ads, or don't, depending on if the Remove Ads IAP has been purchased.
    internal func showAds() {
        //If the "remove ads" IAP hasn't been purchased, show ads
        if (!defaults.bool(forKey: "RemoveAdsPurchased")) {
            createAdBannerView()
            wasPreviouslyShowingAds = true
        }
            //else don't show ads
        else {
            if (wasPreviouslyShowingAds) {
                //Move the photo detail view down to account for the ads being gone now
                photoDetailViewBottomConstraint.constant -= adBannerView.adSize.size.height
                
                adBannerView.removeFromSuperview()
                
                wasPreviouslyShowingAds = false
            }
        }
    }
    
    
    //Load the banner ad
    private func createAdBannerView() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {return}
        let keys = NSDictionary(contentsOfFile: path)!
        
        //CURRENTLY USING A TEST UNIT ID FOR DEVELOPMENT.!!!!!!!
        //SWITCH TO THE REAL UNIT ID BEFORE PUBLISHING
        adBannerView.adUnitID = keys["TestGoogleMobileAdsAdUnitID"] as? String
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
}