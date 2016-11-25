//
//  SettingsViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Properties
    private lazy var selectedSettingsCategory: String = String()
    var iapHelper: IAPHelper = IAPHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the observer
        iapHelper.addPaymentObserver()
        
        /*if (defaults.bool(forKey: "purchased")){
            print("ADS REMOVED HAS BEEN PURCHASED...")
        }*/
    }
    
    
    // MARK: - Methods
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
            if MFMailComposeViewController.canSendMail() {
                let mailController = MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.setToRecipients(["support@vistaweatherapp.com"])
                mailController.setSubject("Question/comment/concern about the Vista Weather app")
                
                present(mailController, animated: true, completion: nil)
            }
        default:
            return
        }
    }
    
    
    //If about to segue, send over the selected settings category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSettingsDetail") {
            guard let segueViewController = segue.destination as? SettingsDetailTableViewController else {return}
            
            segueViewController.currentSettingsCategory = selectedSettingsCategory
        }
    }
}
