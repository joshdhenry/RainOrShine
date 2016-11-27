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
    //Return the abbreviated day (ex: Mon, Tue, Wed, etc)
    var abbreviatedDayString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E"
            return dateFormatter.string(from: self)
        }
    }
}
