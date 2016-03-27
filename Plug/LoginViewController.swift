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
    @IBOutlet weak var usernameOrEmailLabel: VibrantTextField!
    @IBOutlet weak var usernameOrEmailTextField: NSTextField!
    @IBOutlet weak var passwordLabel: VibrantTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var fogotPasswordButton: SwissArmyButton!
    @IBOutlet weak var signUpButton: SwissArmyButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Notifications.subscribe(observer: self, selector: #selector(LoginViewController.displayError(_:)), name: Notifications.DisplayError, object: nil)
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
        HypeMachineAPI.Requests.Misc.getToken(usernameOrEmail: usernameOrEmail, password: password) { result in
            switch result {
            case .Success(let usernameAndToken):
                Authentication.SaveUsername(usernameAndToken.username, withToken: usernameAndToken.token)
                HypeMachineAPI.hmToken = usernameAndToken.token
                self.signedInSuccessfully()
            case .Failure(_, let error):
                var errorMessage: String
                if (error as NSError).code == HypeMachineAPI.ErrorCodes.WrongPassword.rawValue ||
                    (error as NSError).code == HypeMachineAPI.ErrorCodes.WrongUsername.rawValue {
                    errorMessage = "Incorrect Username/Password"
                } else {
                    errorMessage = "Network Error"
                    print(error)
                }
                self.loginButton.buttonState = .Error(errorMessage)
            }
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
        
        // Custom fonts
        usernameOrEmailLabel.font = appFont(size: 12, weight: .Medium)
        usernameOrEmailTextField.font = appFont(size: 18)
        passwordLabel.font = appFont(size: 12, weight: .Medium)
        passwordTextField.font = appFont(size: 18)
        loginButton.font = appFont(size: 14, weight: .Medium)
        fogotPasswordButton.font = appFont(size: 13, weight: .Medium)
        signUpButton.font = appFont(size: 14, weight: .Medium)
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
