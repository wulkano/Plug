//
//  LoginViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/21/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        let username = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        
        HypeMachineAPI.GetToken(username, password: password,
            success: {token in
                Authentication.SaveUsername(username, withToken: token)
                self.signedInSuccessfully()
            }, failure: {error in
                AppError.logError(error)
                NSAlert(error: error).runModal()
        })
    }
    
    func signedInSuccessfully() {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        appDelegate.finishedSigningIn()
    }
    
    @IBAction func forgotPasswordButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://hypem.com/inc/lb_forgot.php"))
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://hypem.com/?signup=1"))
    }
}
