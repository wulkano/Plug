import Cocoa
import HypeMachineAPI

final class LoginViewController: NSViewController, NSTextFieldDelegate {
	@IBOutlet private var usernameOrEmailLabel: VibrantTextField!
	@IBOutlet private var usernameOrEmailTextField: NSTextField!
	@IBOutlet private var passwordLabel: VibrantTextField!
	@IBOutlet private var passwordTextField: NSSecureTextField!
	@IBOutlet private var loginButton: LoginButton!
	@IBOutlet private var fogotPasswordButton: SwissArmyButton!
	@IBOutlet private var signUpButton: SwissArmyButton!

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		Notifications.subscribe(observer: self, selector: #selector(LoginViewController.displayError(_:)), name: Notifications.DisplayError, object: nil)
	}

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	@objc
	func displayError(_ notification: Notification) {
		let error = notification.userInfo!["error"] as! Error
		NSAlert(error: error).runModal()
	}

	func signedInSuccessfully() {
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		appDelegate.finishedSigningIn()
	}

	func loginWithUsernameOrEmail(_ usernameOrEmail: String, andPassword password: String) {
		HypeMachineAPI.Requests.Misc.getToken(
			usernameOrEmail: usernameOrEmail,
			password: password
		) { [weak self] response in
			guard let self = self else {
				return
			}

			switch response.result {
			case .success(let usernameAndToken):
				Authentication.saveUsername(usernameAndToken.username, withToken: usernameAndToken.token)
				HypeMachineAPI.hmToken = usernameAndToken.token
				self.signedInSuccessfully()
			case .failure(let error):
				let errorMessage: String

				if let apiError = error as? HypeMachineAPI.APIError {
					switch apiError {
					case .incorrectUsername,
						 .incorrectPassword,
						 .network(error: HypeMachineAPI.APIError.incorrectUsername),
						 .network(error: HypeMachineAPI.APIError.incorrectPassword):
						errorMessage = "Incorrect Username or Password"
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
		loginButton.buttonState = formFieldsValid() ? .enabled : .disabled
	}

	func formFieldsValid() -> Bool {
		guard !formFieldsEmpty() else {
			return false
		}

		return true
	}

	func formFieldsEmpty() -> Bool {
		usernameOrEmailTextField.stringValue.isEmpty
			|| passwordTextField.stringValue.isEmpty
	}

	// MARK: Actions

	@IBAction private func loginButtonClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Log In")
		let usernameOrEmail = usernameOrEmailTextField.stringValue
		let password = passwordTextField.stringValue

		loginButton.buttonState = .sending
		loginWithUsernameOrEmail(usernameOrEmail, andPassword: password)
	}

	@IBAction private func forgotPasswordButtonClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Forgot Password")
		"https://hypem.com/?forgot=1".openUrl()
	}

	@IBAction private func signUpButtonClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Sign Up")
		"https://hypem.com/?signup=1".openUrl()
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
}

extension LoginViewController: NSControlTextEditingDelegate {
	func controlTextDidChange(_ notification: Notification) {
		formFieldsChanged()
	}
}
