//
//  DateExtension.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/9/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation

extension Date {
    
    // MARK: - Methods
    //TODO: -CHANGE THIS TO A COMPUTED VAR
    //Return the abbreviated day (ex: Mon, Tue, Wed, etc)
    func toAbbreviatedDayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
}
