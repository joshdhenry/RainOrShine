//
//  SettingsViewController.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/5/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - Properties
    private lazy var selectedSettingsCategory: String = String()
    
    
    // MARK: - Methods
    //If a cell is tapped, generate the variable to send to SettingsDetailTableViewController and segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            selectedSettingsCategory = "Temperature Unit"
        case (0, 1):
            selectedSettingsCategory = "Update Weather Every"
        case (1, 0):
            selectedSettingsCategory = "Use Default Photos"
        case (1, 1):
            selectedSettingsCategory = "Change Photo Every"
        default:
            return
        }
        performSegue(withIdentifier: "segueSettingsDetail", sender: self)
    }
    
    
    //If about to segue, send over the selected settings category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSettingsDetail") {
            guard let segueViewController = segue.destination as? SettingsDetailTableViewController else {return}
            
            segueViewController.currentSettingsCategory = selectedSettingsCategory
        }
    }
}
