//
//  SettingsDetailTableViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/21/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

class SettingsDetailTableViewController: UITableViewController {
    // MARK: - Properties
    public var currentSettingsCategory: String!
    private let settingsCategoryTableViewItemStrings: [String : [String]] = ["Temperature Unit" : ["Fahrenheit", "Celcius"],
                                                                     "Update Weather Every" : ["15 Minutes", "30 Minutes", "60 Minutes"],
                                                                     "Use Default Photos" : ["When No Location Photos Available", "Always", "Never"],
                                                                     "Change Photo Every" : ["1 Minute", "3 Minutes", "5 Minutes", "10 Minutes", "30 Minutes", "Never"]]
    
    
    // MARK: - Methods
    override func viewDidLoad() {
        self.title = currentSettingsCategory
    }
    
    
    //Number of table view rows is the number of settings for the current settings category
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settingsList = settingsCategoryTableViewItemStrings[currentSettingsCategory] else {return 0}
        return settingsList.count
    }
    
    
    //Populate table view cells with all the settings for the current settings category
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsDetailCell")! as UITableViewCell
        let settingsList = settingsCategoryTableViewItemStrings[currentSettingsCategory]
        cell.textLabel?.text = settingsList?[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        return cell
    }
}
