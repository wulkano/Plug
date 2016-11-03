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
    
    func displayError(_ notification: Notification) {
        let error = (notification as NSNotification).userInfo!["error"] as! NSError
        NSAlert(error: error).runModal()
    }
    
    func signedInSuccessfully() {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.finishedSigningIn()
    }
    
    func loginWithUsernameOrEmail(_ usernameOrEmail: String, andPassword password: String) {
        HypeMachineAPI.Requests.Misc.getToken(usernameOrEmail: usernameOrEmail, password: password) { response in
            switch response.result {
            case .success(let usernameAndToken):
                Authentication.SaveUsername(usernameAndToken.username, withToken: usernameAndToken.token)
                HypeMachineAPI.hmToken = usernameAndToken.token
                self.signedInSuccessfully()
            case .failure(let error):
                var errorMessage: String
                
                if let apiError = error as? HypeMachineAPI.APIError {
                    switch apiError {
                    case HypeMachineAPI.APIError.incorrectUsername,
                         HypeMachineAPI.APIError.incorrectPassword:
                        errorMessage = "Incorrect Username/Password"
                    default:
                        errorMessage = "Network Error"
                    }
                } else {
                    errorMessage = "Network Error"
                }
                
                self.loginButton.buttonState = .error(errorMessage)
            }
        }
    }
    
    func formFieldsChanged() {
        if formFieldsValid() {
            loginButton.buttonState = .enabled
        } else {
            loginButton.buttonState = .disabled
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
    
    @IBAction func loginButtonClicked(_ sender: AnyObject) {
        Analytics.trackButtonClick("Log In")
        let usernameOrEmail = usernameOrEmailTextField.stringValue
        let password = passwordTextField.stringValue
        
        loginButton.buttonState = .sending
        loginWithUsernameOrEmail(usernameOrEmail, andPassword: password)
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: AnyObject) {
        Analytics.trackButtonClick("Forgot Password")
        NSWorkspace.shared().open(URL(string: "https://hypem.com/inc/lb_forgot.php")!)
    }
    
    @IBAction func signUpButtonClicked(_ sender: AnyObject) {
        Analytics.trackButtonClick("Sign Up")
        NSWorkspace.shared().open(URL(string: "http://hypem.com/?signup=1")!)
    }
    
    // MARK: NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameOrEmailTextField.delegate = self
        passwordTextField.delegate = self
        usernameOrEmailTextField.nextKeyView = passwordTextField
        passwordTextField.nextKeyView = usernameOrEmailTextField
        
        // Custom fonts
        usernameOrEmailLabel.font = appFont(size: 12, weight: .medium)
        usernameOrEmailTextField.font = appFont(size: 18)
        passwordLabel.font = appFont(size: 12, weight: .medium)
        passwordTextField.font = appFont(size: 18)
        loginButton.font = appFont(size: 14, weight: .medium)
        fogotPasswordButton.font = appFont(size: 13, weight: .medium)
        signUpButton.font = appFont(size: 14, weight: .medium)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window!.initialFirstResponder = usernameOrEmailTextField
    }
    
    // MARK: NSTextFieldDelegate
    
    override func controlTextDidChange(_ notification: Notification) {
        formFieldsChanged()
    }
}
