//
//  SettingsTableViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

//SettingsTableViewController is the table view controller that is the main control center for changing any settings for the app.
class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    // MARK: UI Elements
    @IBOutlet weak var temperatureUnitCellSubtitle: UILabel!
    @IBOutlet weak var updateWeatherIntervalCellSubtitle: UILabel!
    @IBOutlet weak var useDefaultPhotosCellSubtitle: UILabel!
    @IBOutlet weak var changePhotoIntervalCellSubtitle: UILabel!
    @IBOutlet weak var nightStandModeSwitch: UISwitch!
    
    // MARK: Constants
    private let iapHelper: IAPHelper = IAPHelper()

    internal let purchasesRestoredNotification = Notification.Name(rawValue:"purchasesRestored")
    internal let purchasesRestoreFailureNotification = Notification.Name(rawValue:"purchasesRestoreFailed")
    internal let purchaseFailureNotification = Notification.Name(rawValue:"purchaseFailed")
    
    
    // MARK: Variables
    private var currentSettings = Settings()
    private lazy var selectedSettingsCategory: String = String()
    
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
    
    // MARK: UITableViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        createPurchaseUpdatesObservers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        initializeViewModel()
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
        case (2, 0):
            presentNightStandInfoAlert()
        case (3, 0):
            guard (currentNetworkConnectionStatus != .notReachable) else {
                alertNoNetworkConnection()
                break
            }
            iapHelper.removePaymentQueueObserver()
            iapHelper.addPaymentQueueObserver()
            presentRemoveAdsAlert()
        case (3, 1):
            composeMail()
        case (3, 2):
            UIApplication.shared.openURL(NSURL(string: "http://www.vistaweatherapp.com")! as URL)
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //If the night stand info button accessory is tapped, call the method to display an informational alert
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if ((indexPath.section, indexPath.row) == (2,0)) {
            presentNightStandInfoAlert()
        }
    }
    
    
    // MARK: Initialize View Model
    private func initializeViewModel() {
        viewModel = SettingsViewModel(temperatureUnit: currentSettings.temperatureUnit,
                                      updateWeatherInterval: currentSettings.updateWeatherInterval,
                                      useDefaultPhotos: currentSettings.useDefaultPhotos,
                                      changePhotoInterval: currentSettings.changePhotoInterval,
                                      nightStandModeOn: currentSettings.nightStandModeOn)
    }
    
    
    // MARK: Night Stand Methods
    //Present an alert that tells the user what night stand mode is and how it works
    func presentNightStandInfoAlert() {
        displaySimpleAlert(title: "Night Stand Mode", message: "Night Stand Mode prevents your device from locking and going to sleep as long as your device is on the charger.", buttonText: "OK")
    }
    
    
    //If the night stand mode switch is changed, set the currentSettings for it
    @IBAction func nightStandModeOnSwitchValueChanged(_ sender: Any) {
        currentSettings.nightStandModeOn = nightStandModeSwitch.isOn
    }
    
    
    // MARK: Ad Methods
    func presentRemoveAdsAlert() {
        let gpsAlert = UIAlertController(title: "Remove Ads", message: "This app has ads that can be removed by purchasing the 'Remove Ads' in-app purchase.", preferredStyle: .alert)
        gpsAlert.addAction(UIAlertAction(title: "Purchase", style: UIAlertActionStyle.default, handler: purchaseRemoveAds))
        gpsAlert.addAction(UIAlertAction(title: "Restore Purchase", style: UIAlertActionStyle.default, handler: restorePurchaseRemoveAds))
        gpsAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(gpsAlert, animated: true, completion: nil)
    }
    
    
    //Purchase the removal of ads
    func purchaseRemoveAds(alertAction: UIAlertAction) {
        iapHelper.startProductRequest(productID: Products.removeAds)
    }
    
    
    //Restore any previous purchases made
    func restorePurchaseRemoveAds(alertAction: UIAlertAction) {
        iapHelper.restorePurchases()
    }
    
    
    //If about to segue, send over the selected settings category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSettingsDetail") {
            guard let segueViewController = segue.destination as? SettingsDetailTableViewController else {return}
            
            segueViewController.currentSettingsCategory = selectedSettingsCategory
        }
    }
}
