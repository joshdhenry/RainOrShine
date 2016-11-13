//
//  LocationView.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/4/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import UIKit

class LocationView: UIVisualEffectView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var viewModel: LocationViewModel? {
        didSet {
            viewModel?.currentGeneralLocalePlace.observe { [unowned self] in
                print("Changing location label....")
                if ($0 != nil) {
                    self.locationLabel.text = $0?.gmsPlace?.formattedAddress!.components(separatedBy: ", ").joined(separator: "\n")
                }
                else {
                    self.locationLabel.text = ""
                }
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "LocationView", bundle: nil).instantiate(withOwner: self, options: nil)
        
        setViewStyle()
        
        addSubview(view)
        
        initializeViewModel()
    }
    
    
    func initializeViewModel() {
        print("Initializing location view model...")
        self.viewModel = LocationViewModel()
    }
    
    
    private func setViewStyle() {
        self.setViewEdges()
        
        self.locationLabel.textColor = UIColor.white
    }
}
