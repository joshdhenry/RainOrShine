//
//  PhotoDetailView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit
import GooglePlaces

class PhotoDetailView: UIVisualEffectView, WeatherViewControllerSubView {
    // MARK: - Properties
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var photoAttributionLabel: UILabel!
    @IBOutlet weak var photoPageControl: UIPageControl!

    // MARK: View Model
    var viewModel: PhotoDetailViewModel? {
        didSet {
            viewModel?.currentPlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.isHidden = false
                    self.fadeIn()
                }
                else {
                    self.isHidden = true
                }
            }
            
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let currentPlace: Place = LocationAPIService.currentPlace else {
                    //Place is nil.  App must be just starting
                    self.photoPageControl.isHidden = true
                    self.photoPageControl.currentPage = 0
                    
                    self.photoAttributionLabel.isHidden = true
                    
                    return
                }
                
                if (currentPlace.generalLocalePhotoArray.count > 0) {
                    self.photoPageControl.isHidden = false
                    self.photoPageControl.currentPage = $0!
                    
                    guard let photoMetaData: GMSPlacePhotoMetadata = currentPlace.generalLocalePhotoMetaDataArray[$0!] else {
                        self.photoAttributionLabel.isHidden = true
                        return
                    }
                    
                    //This can be tested by using Oirschot, Netherlands as the location.  One photo does not have an attribution.
                    guard let photoAttributions = photoMetaData.attributions else {
                        self.photoAttributionLabel.text = ""
                        self.photoAttributionLabel.isHidden = true
                        return
                    }
                    
                    let attributionPrefixAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 12)]
                    let attributionPrefixString: NSMutableAttributedString = NSMutableAttributedString(string: "Photo by ", attributes: attributionPrefixAttributes)
                    let completeAttributionString = NSMutableAttributedString()
                    
                    completeAttributionString.append(attributionPrefixString)
                    completeAttributionString.append(photoAttributions)
                    
                    self.photoAttributionLabel.attributedText = completeAttributionString
                    self.photoAttributionLabel.isHidden = false
                }
                else {
                    self.photoPageControl.isHidden = true
                    self.photoPageControl.currentPage = 0
                    self.photoAttributionLabel.isHidden = true
                }
            }
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "PhotoDetailView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
        
        initializeViewModel()
    }
    
    
    // MARK: - Methods
    internal func initializeViewModel() {
        print("Initializing photo detail view model...")
        self.viewModel = PhotoDetailViewModel()
    }
    
    
    internal func setViewStyle() {
        self.setViewEdges()
        
        self.photoAttributionLabel.textColor = UIColor.white
    }
    

    //Advance forwards or backwards through page numbers, accounting for total number of pages
    public func advancePage(direction: UISwipeGestureRecognizerDirection) -> Int {
        if (direction == UISwipeGestureRecognizerDirection.left) {
            if (self.photoPageControl.currentPage < self.photoPageControl.numberOfPages - 1) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.currentPage + 1))
            }
        }
        else {
            if (self.photoPageControl.currentPage > 0) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.currentPage - 1))
            }
        }
        return self.photoPageControl.currentPage
    }
}

