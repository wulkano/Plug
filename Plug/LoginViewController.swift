//
//  LoginViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/21/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var usernameOrEmailTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet var loginButton: LoginButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Notifications.Subscribe.DisplayError(self, selector: "displayError:")
    }
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameOrEmailTextField.delegate = self
        passwordTextField.delegate = self
        usernameOrEmailTextField.nextKeyView = passwordTextField
        passwordTextField.nextKeyView = usernameOrEmailTextField
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window!.initialFirstResponder = usernameOrEmailTextField
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
        Analytics.sharedInstance.trackButtonClick("Log In")
        let usernameOrEmail = usernameOrEmailTextField.stringValue
        let password = passwordTextField.stringValue
        
        loginButton.buttonState = .Sending
        loginWithUsernameOrEmail(usernameOrEmail, andPassword: password)
    }
    
    func loginWithUsernameOrEmail(usernameOrEmail: String, andPassword password: String) {
        HypeMachineAPI.GetToken(usernameOrEmail, password: password,
            success: { username, token in
                Authentication.SaveUsername(username, withToken: token)
                self.signedInSuccessfully()
            }, failure: { error in
                // TODO: Better appwide errors
                var errorMessage: String
                if error.localizedDescription == "Wrong password" {
                    errorMessage = "Incorrect username/password"
                } else {
                    errorMessage = "Network Error"
                    Logger.LogError(error)
                }
                self.loginButton.buttonState = .Error(errorMessage)
        })
    }
    
    @IBAction func forgotPasswordButtonClicked(sender: AnyObject) {
        Analytics.sharedInstance.trackButtonClick("Forgot Password")
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://hypem.com/inc/lb_forgot.php")!)
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        Analytics.sharedInstance.trackButtonClick("Sign Up")
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://hypem.com/?signup=1")!)
    }
    
    override func controlTextDidChange(notification: NSNotification) {
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
        return  usernameOrEmailTextField.stringValue == "" || passwordTextField.stringValue == ""
    }
    
}
