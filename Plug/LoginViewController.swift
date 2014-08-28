//
//  LoginViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/21/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet var loginButton: LoginButton!
    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
        
        Notifications.Subscribe.DisplayError(self, selector: "displayError:")
    }
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.nextKeyView = passwordTextField
        passwordTextField.nextKeyView = usernameTextField
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window!.initialFirstResponder = usernameTextField
    }
    
    func displayError(notification: NSNotification) {
        let error = Notifications.Read.ErrorNotification(notification)
        NSAlert(error: error).runModal()
    }
    
    func signedInSuccessfully() {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        appDelegate.finishedSigningIn()
    }
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        let username = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        
        loginButton.buttonState = .Sending
        loginWithUsername(username, andPassword: password)
    }
    
    func loginWithUsername(username: String, andPassword password: String) {
        HypeMachineAPI.GetToken(username, password: password,
            success: {token in
                Authentication.SaveUsername(username, withToken: token)
                self.signedInSuccessfully()
            }, failure: {error in
                // TODO: Better appwide passwords
                var errorMessage: String
                if error.localizedDescription == "Wrong password" {
                    errorMessage = "Incorrect username/password"
                } else {
                    errorMessage = "Network Error"
                    Notifications.Post.DisplayError(error, sender: self)
                    Logger.LogError(error)
                }
                self.loginButton.buttonState = .Error(errorMessage)
        })
    }
    
    @IBAction func forgotPasswordButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://hypem.com/inc/lb_forgot.php"))
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://hypem.com/?signup=1"))
    }
    
    override func controlTextDidChange(notification: NSNotification!) {
        formFieldsChanged()
    }
    
    func formFieldsChanged() {
        if formFieldsValid() {
            loginButton.buttonState = .Enabled
        } else {
            loginButton.buttonState = .Disabled
        }
    }
    
    func formFieldsValid() -> Bool {
        if formFieldsEmpty() { return false }
        
        return true
    }
    
    func formFieldsEmpty() -> Bool {
        return  usernameTextField.stringValue == "" || passwordTextField.stringValue == ""
    }
}
