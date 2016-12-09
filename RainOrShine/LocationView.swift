//
//  LocationView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/4/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

//LocationView shows the general location address of the current location loaded into the app
class LocationView: UIVisualEffectView, WeatherViewControllerSubView {
    
    // MARK: - Properties
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: View Model
    var viewModel: LocationViewModel? {
        didSet {
            viewModel?.currentGeneralLocalePlace.observe { [unowned self] in
                if ($0 != nil) {
                    self.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                    self.isHidden = false
                    self.fadeIn()
                }
                else {
                    self.locationLabel.text = ""
                    self.isHidden = true
                }
            }
        }
    }
    
    
    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "LocationView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)        
    }
    
    
    internal func setViewStyle() {
        self.setViewEdges()
        
        self.locationLabel.textColor = UIColor.white
    }
}
