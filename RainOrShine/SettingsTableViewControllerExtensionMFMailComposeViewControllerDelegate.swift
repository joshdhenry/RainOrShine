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


//Handle all methods relating to composing an email to support@vistaweather.com.
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    // MARK: - Methods
    
    //Begin composing email to support
    internal func composeMail() {
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients(["support@vistaweatherapp.com"])
            mailController.setSubject("Question/comment/concern about the Vista Weather app")
            
            present(mailController, animated: true, completion: nil)
        }
        else {
            displaySimpleAlert(title: "Email Error", message: "Sorry, this device is not configured to send messages.", buttonText: "OK")
        }
    }
    
    
    //If the mail compose controller is finished, dismiss it
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
