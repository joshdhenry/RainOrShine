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

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "PhotoDetailView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
    }
    
    
    private func setViewStyle() {
        self.setViewEdges()
        
        self.photoAttributionLabel.textColor = UIColor(netHex: ColorScheme.lightGray)
    }
}

