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
    var currentSettings = Settings()
    var checkedCell: UITableViewCell?
    
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

        var currentSettingRawValue: String = String()
        
        switch (currentSettingsCategory) {
        case "Temperature Unit":
            currentSettingRawValue = currentSettings.temperatureUnit.rawValue
        case "Update Weather Every":
            currentSettingRawValue = currentSettings.updateWeatherInterval.rawValue
        case "Use Default Photos":
            currentSettingRawValue = currentSettings.useDefaultPhotos.rawValue
        case "Change Photo Every":
            currentSettingRawValue = currentSettings.changePhotoInterval.rawValue
        default:
            return cell
        }
        
        if (currentSettingRawValue != settingsList?[indexPath.row]) {
            cell.accessoryType = .none
        }
        else {
            checkedCell = cell
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let currentCellText: String = currentCell.textLabel?.text ?? ""
        
        checkedCell?.accessoryType = .none
        currentCell.accessoryType = .checkmark
        checkedCell = currentCell
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (currentSettingsCategory) {
        case "Temperature Unit":
            currentSettings.temperatureUnit = Settings.TemperatureUnitSetting(rawValue: currentCellText) ?? Settings.TemperatureUnitSetting.fahrenheit
            
            
            
            
            
            
            /////
            var weatherAPIService: WeatherAPIService = WeatherAPIService()

            var currentWeatherViewModel = CurrentWeatherViewModel(forecast: weatherAPIService.currentWeatherForecast)
            currentWeatherViewModel.updateForecast(newForecast: weatherAPIService.currentWeatherForecast)
            
            
            
            
            
            
            
        case "Update Weather Every":
            currentSettings.updateWeatherInterval = Settings.UpdateWeatherIntervalSetting(rawValue: currentCellText) ?? Settings.UpdateWeatherIntervalSetting.thirty
        case "Use Default Photos":
            currentSettings.useDefaultPhotos = Settings.UseDefaultPhotosSetting(rawValue: currentCellText) ?? Settings.UseDefaultPhotosSetting.whenNoPictures
        case "Change Photo Every":
            currentSettings.changePhotoInterval = Settings.ChangePhotoIntervalSetting(rawValue: currentCellText) ?? Settings.ChangePhotoIntervalSetting.three
        default:
            break
        }
    }
}
