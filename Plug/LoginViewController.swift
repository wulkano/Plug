//
//  LoginViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/21/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class LoginViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var usernameOrEmailTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet var loginButton: LoginButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Notifications.subscribe(observer: self, selector: "displayError:", name: Notifications.DisplayError, object: nil)
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func displayError(notification: NSNotification) {
        let error = notification.userInfo!["error"] as! NSError
        NSAlert(error: error).runModal()
    }
    
    func signedInSuccessfully() {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.finishedSigningIn()
    }
    
    func loginWithUsernameOrEmail(usernameOrEmail: String, andPassword password: String) {
        HypeMachineAPI.Requests.Misc.getToken(usernameOrEmail: usernameOrEmail, password: password) {
            (username, token, error) in
            
            if error != nil {
                var errorMessage: String
                if error!.localizedDescription == "Wrong password" {
                    errorMessage = "Incorrect username/password"
                } else {
                    errorMessage = "Network Error"
                    println(error!)
                }
                self.loginButton.buttonState = .Error(errorMessage)
                return
            }
            
            Authentication.SaveUsername(username!, withToken: token!)
            HypeMachineAPI.hmToken = token!
            self.signedInSuccessfully()
        }
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
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Log In")
        let usernameOrEmail = usernameOrEmailTextField.stringValue
        let password = passwordTextField.stringValue
        
        loginButton.buttonState = .Sending
        loginWithUsernameOrEmail(usernameOrEmail, andPassword: password)
    }
    
    @IBAction func forgotPasswordButtonClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Forgot Password")
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://hypem.com/inc/lb_forgot.php")!)
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Sign Up")
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://hypem.com/?signup=1")!)
    }
    
    // MARK: NSViewController
    
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
    
    // MARK: NSTextFieldDelegate
    
    override func controlTextDidChange(notification: NSNotification) {
        formFieldsChanged()
    }
}
