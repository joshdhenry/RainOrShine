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
            viewModel?.currentGeneralLocalePlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.isHidden = false
                    self.fadeIn()
                }
                else {
                    self.isHidden = true
                }
            }
            
            viewModel?.currentPlaceImageIndex.observe { [unowned self] in
                guard let currentPlaceImageIndex = $0 else {
                    //Place is nil.  App must be just starting
                    self.photoPageControl.isHidden = true
                    self.photoPageControl.currentPage = 0
                    
                    self.photoAttributionLabel.isHidden = true
                    
                    return
                }
                
                guard let thisCurrentGeneralLocalePlace = self.viewModel?.currentGeneralLocalePlace.value else {return}
                
                if (!thisCurrentGeneralLocalePlace.photoArray.isEmpty) {
                    self.photoPageControl.isHidden = false
                    self.photoPageControl.currentPage = currentPlaceImageIndex
                    self.photoPageControl.numberOfPages = thisCurrentGeneralLocalePlace.photoArray.count
                    
                    guard let photoMetaData: GMSPlacePhotoMetadata = thisCurrentGeneralLocalePlace.photoMetaDataArray[currentPlaceImageIndex] else {
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
                    self.photoPageControl.numberOfPages = 0
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
    }
    
    
    
    internal func setViewStyle() {
        self.setViewEdges()
        
        self.photoAttributionLabel.textColor = UIColor.white
    }
    

    //Advance forwards or backwards through page numbers, accounting for total number of pages
    public func advancePage(direction: UISwipeGestureRecognizerDirection, place: Place) -> Int {
        if (direction == UISwipeGestureRecognizerDirection.left) {
            if (self.photoPageControl.currentPage < self.photoPageControl.numberOfPages - 1) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.currentPage + 1), place: place)
            }
        }
        else {
            if (self.photoPageControl.currentPage > 0) {
                self.viewModel?.updatePlaceImageIndex(newPlaceImageIndex: (self.photoPageControl.currentPage - 1), place: place)
            }
        }
        return self.photoPageControl.currentPage
    }
}

