//
//  SettingsTableViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet weak var temperatureUnitCellSubtitle: UILabel!
    @IBOutlet weak var updateWeatherIntervalCellSubtitle: UILabel!
    @IBOutlet weak var useDefaultPhotosCellSubtitle: UILabel!
    @IBOutlet weak var changePhotoIntervalCellSubtitle: UILabel!
    @IBOutlet weak var nightStandModeSwitch: UISwitch!
    
    private lazy var selectedSettingsCategory: String = String()
    private var currentSettings = Settings()
    private var iapHelper: IAPHelper = IAPHelper()
    
    private let alertPurchasesRestoredNotification = Notification.Name(rawValue:"alertPurchasesRestored")
    private let alertPurchasesRestoreFailureNotification = Notification.Name(rawValue:"alertPurchasesRestoreFailed")
    
    
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
        
        createPaymentUpdatesObservers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel = SettingsViewModel(temperatureUnit: currentSettings.temperatureUnit,
                                      updateWeatherInterval: currentSettings.updateWeatherInterval,
                                      useDefaultPhotos: currentSettings.useDefaultPhotos,
                                      changePhotoInterval: currentSettings.changePhotoInterval,
                                      nightStandModeOn: currentSettings.nightStandModeOn)
    }
    
    
    //Create the observers to catch notifications sent from Settings Detail Table View Controller
    private func createPaymentUpdatesObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: alertPurchasesRestoredNotification, object: nil, queue: nil, using: catchAlertPurchasesRestoredNotification)
        notificationCenter.addObserver(forName: alertPurchasesRestoreFailureNotification, object: nil, queue: nil, using: catchAlertPurchasesRestoreFailureNotification)
    }
    
    
    //Catch notification center notifications
    func catchAlertPurchasesRestoredNotification(notification:Notification) -> Void {
        let purchasesRestoredAlert = UIAlertController(title: "Purchases Restored", message: "Any prior purchases you have made have now been restored.", preferredStyle: .alert)
        purchasesRestoredAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(purchasesRestoredAlert, animated: true, completion: nil)
    }
    
    
    //Catch notification center notifications
    func catchAlertPurchasesRestoreFailureNotification(notification:Notification) -> Void {
        let purchasesRestoreFailureAlert = UIAlertController(title: "Purchase Restore Failed", message: "There was a problem restoring prior purchases.", preferredStyle: .alert)
        purchasesRestoreFailureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(purchasesRestoreFailureAlert, animated: true, completion: nil)
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
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if ((indexPath.section, indexPath.row) == (2,0)) {
            presentNightStandInfoAlert()
        }
    }
    
    
    func presentNightStandInfoAlert() {
        let nightStandModeInfoAlert = UIAlertController(title: "Night Stand Mode", message: "Night Stand Mode prevents your device from locking and going to sleep as long as your device is on the charger.", preferredStyle: .alert)
        nightStandModeInfoAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(nightStandModeInfoAlert, animated: true, completion: nil)
    }
    
    
    func presentRemoveAdsAlert() {
        let gpsAlert = UIAlertController(title: "Remove Ads", message: "This app has ads that can be removed by purchasing the 'Remove Ads' in-app purchase.", preferredStyle: .alert)
        gpsAlert.addAction(UIAlertAction(title: "Purchase", style: UIAlertActionStyle.default, handler: purchaseRemoveAds))
        gpsAlert.addAction(UIAlertAction(title: "Restore Purchase", style: UIAlertActionStyle.default, handler: restorePurchaseRemoveAds))
        gpsAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(gpsAlert, animated: true, completion: nil)
    }
    
    
    func purchaseRemoveAds(alertAction: UIAlertAction) {
        iapHelper.startProductRequest(productID: Products.removeAds)
    }
    
    
    func restorePurchaseRemoveAds(alertAction: UIAlertAction) {
        iapHelper.restorePurchases()
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
