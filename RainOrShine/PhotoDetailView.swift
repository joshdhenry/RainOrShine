//
//  PhotoDetailView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/7/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class PhotoDetailView: UIVisualEffectView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var photoAttributionLabel: UILabel!
    @IBOutlet weak var photoPageControl: UIPageControl!

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
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "PhotoDetailView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
        
        initializeViewModel()
    }
    
    
    func initializeViewModel() {
        print("Initializing location view model...")
        self.viewModel = PhotoDetailViewModel()
    }
    
    
    private func setViewStyle() {
        self.setViewEdges()
        
        self.photoAttributionLabel.textColor = UIColor.white
    }
}

