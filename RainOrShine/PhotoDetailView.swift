//
//  PhotoDetailView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import GooglePlaces

//PhotoDetailView is the view that shows photo attributions and a page control.
class PhotoDetailView: UIVisualEffectView, WeatherViewControllerSubView {
    // MARK: - Properties
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var photoAttributionLabel: UILabel!
    @IBOutlet weak var photoPageControl: UIPageControl!

    // MARK: View Model
    var viewModel: PhotoDetailViewModel? {
        didSet {
            viewModel?.currentGeneralLocalePlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.isHidden = false
                    self.fadeIn()
                }
                else {
                    //Place is nil.  App must be just starting
                    self.isHidden = true
                }
            }
            
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let currentPlaceImageIndex = $0 else {
                    //Place index is nil.  App must be just starting or has no photos and default photos are turned off
                    self.isHidden = true
                    self.photoPageControl.currentPage = 0

                    return
                }
                
                guard let thisCurrentGeneralLocalePlace = self.viewModel?.currentGeneralLocalePlace.value else {return}
                
                let completeAttributionString = NSMutableAttributedString()
                let attributionPrefixAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 12)]
                let attributionPrefixString: NSMutableAttributedString = NSMutableAttributedString(string: "Photo by ", attributes: attributionPrefixAttributes)
    
                completeAttributionString.append(attributionPrefixString)
                
                self.photoPageControl.isHidden = false
                self.photoPageControl.currentPage = currentPlaceImageIndex
                
                let currentSettings = Settings()
                
                if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    currentSettings.useDefaultPhotos != .always) {
                    self.photoPageControl.numberOfPages = thisCurrentGeneralLocalePlace.photoArray.count

                    guard let photoMetaData: GMSPlacePhotoMetadata = thisCurrentGeneralLocalePlace.photoMetaDataArray[currentPlaceImageIndex] else {
                        self.photoAttributionLabel.isHidden = true

                        return
                    }
                    
                    //This block can be tested by using Oirschot, Netherlands as the location.  One photo does not have an attribution.
                    guard let photoAttributions = photoMetaData.attributions else {
                        self.photoAttributionLabel.text = ""
                        self.photoAttributionLabel.isHidden = true

                        return
                    }
                    
                    completeAttributionString.append(photoAttributions)
                }
                else if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    currentSettings.useDefaultPhotos == .always) {
                    //Use the default photos array
                    self.photoPageControl.numberOfPages = DefaultPhotoAttributions.defaultPhotoAttributionsArray.count
                    let photoAttributions: NSAttributedString = NSAttributedString(string: DefaultPhotoAttributions.defaultPhotoAttributionsArray[currentPlaceImageIndex])
                    completeAttributionString.append(photoAttributions)
                }
                else if (thisCurrentGeneralLocalePlace.photoArray.isEmpty &&
                    currentSettings.useDefaultPhotos != .never){
                    //Use the default photos array
                    self.photoPageControl.numberOfPages = DefaultPhotoAttributions.defaultPhotoAttributionsArray.count
                    let photoAttributions: NSAttributedString = NSAttributedString(string: DefaultPhotoAttributions.defaultPhotoAttributionsArray[currentPlaceImageIndex])
                    completeAttributionString.append(photoAttributions)
                }
                self.photoAttributionLabel.attributedText = completeAttributionString
                self.photoAttributionLabel.isHidden = false
            }
        }
    }
    

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "PhotoDetailView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
    }
    
    
    // MARK: - Methods
    internal func setViewStyle() {
        self.setViewEdges()
        
        self.photoAttributionLabel.textColor = UIColor.white
    }
    

    //Advance forwards or backwards through page numbers, accounting for total number of pages. If looping is enabled, it will wrap around once it has reached the last image.
    public func advancePage(direction: UISwipeGestureRecognizerDirection, place: Place, looping: Bool) -> Int{
        if (direction == UISwipeGestureRecognizerDirection.left) {
            if (self.photoPageControl.currentPage == (self.photoPageControl.numberOfPages - 1) &&
                looping) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: 0, place: place)
            }
            else if (self.photoPageControl.currentPage < self.photoPageControl.numberOfPages - 1) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.currentPage + 1), place: place)
            }
        }
        else if (direction == UISwipeGestureRecognizerDirection.right) {
            if (self.photoPageControl.currentPage == 0 &&
                looping) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.numberOfPages - 1), place: place)
            }
            else if (self.photoPageControl.currentPage > 0) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.currentPage - 1), place: place)
            }
        }
        return self.photoPageControl.currentPage
    }
}

