//
//  SettingsTableViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet weak var temperatureUnitCellSubtitle: UILabel!
    @IBOutlet weak var updateWeatherIntervalCellSubtitle: UILabel!
    @IBOutlet weak var useDefaultPhotosCellSubtitle: UILabel!
    @IBOutlet weak var changePhotoIntervalCellSubtitle: UILabel!
    @IBOutlet weak var nightStandModeSwitch: UISwitch!
    
    private lazy var selectedSettingsCategory: String = String()
    var currentSettings = Settings()
    var iapHelper: IAPHelper = IAPHelper()
    
    
    // MARK: View Model
    var viewModel: SettingsViewModel? {
        didSet {
            viewModel?.currentTemperatureUnit.observe { [unowned self] in
                self.temperatureUnitCellSubtitle.text = $0?.rawValue
            }
            viewModel?.currentUpdateWeatherInterval.observe { [unowned self] in
                self.updateWeatherIntervalCellSubtitle.text = $0?.rawValue
            }
            viewModel?.currentUseDefaultPhotos.observe { [unowned self] in
                self.useDefaultPhotosCellSubtitle.text = $0?.rawValue
            }
            viewModel?.currentChangePhotoInterval.observe { [unowned self] in
                self.changePhotoIntervalCellSubtitle.text = $0?.rawValue
            }
            viewModel?.currentNightStandModeOn.observe { [unowned self] in
                let nightStandModeSwitchOn = $0 ?? false
                self.nightStandModeSwitch.setOn(nightStandModeSwitchOn, animated: false)
            }
        }
    }
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsTableViewController.goBack(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //print("In viewWillAppear...")
        
        viewModel = SettingsViewModel(temperatureUnit: currentSettings.temperatureUnit,
                                      updateWeatherInterval: currentSettings.updateWeatherInterval,
                                      useDefaultPhotos: currentSettings.useDefaultPhotos,
                                      changePhotoInterval: currentSettings.changePhotoInterval,
                                      nightStandModeOn: currentSettings.nightStandModeOn)
    }
    
    
    func goBack(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    //If a cell is tapped, generate the variable to send to SettingsDetailTableViewController and segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            selectedSettingsCategory = "Temperature Unit"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (0, 1):
            selectedSettingsCategory = "Update Weather Every"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (1, 0):
            selectedSettingsCategory = "Use Default Photos"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (1, 1):
            selectedSettingsCategory = "Change Photo Every"
            performSegue(withIdentifier: "segueSettingsDetail", sender: self)
        case (3, 0):
            iapHelper.startProductRequest(productID: Products.removeAds)
        case (3, 1):
            composeMail()
        case (3, 2):
            UIApplication.shared.openURL(NSURL(string: "http://www.vistaweatherapp.com")! as URL)
        default:
            return
        }
    }
    
    
    //If the night stand mode switch is changed, set the currentSettings for it
    @IBAction func nightStandModeOnSwitchValueChanged(_ sender: Any) {
        currentSettings.nightStandModeOn = nightStandModeSwitch.isOn
    }
    
    
    //If about to segue, send over the selected settings category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSettingsDetail") {
            guard let segueViewController = segue.destination as? SettingsDetailTableViewController else {return}
            
            segueViewController.currentSettingsCategory = selectedSettingsCategory
        }
    }
}
