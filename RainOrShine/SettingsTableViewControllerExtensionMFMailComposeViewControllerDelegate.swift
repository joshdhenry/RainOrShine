//
//  SettingsTableViewControllerExtensionMFMailComposeViewControllerDelegate.swift
//  RainOrShine
//
//  Created by Josh Henry on 11/24/16.
//  Copyright © 2016 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    internal func composeMail() {
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients(["support@vistaweatherapp.com"])
            mailController.setSubject("Question/comment/concern about the Vista Weather app")
            
            present(mailController, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Email Error", message: "Sorry, this device is not configured to send messages.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
