import Cocoa

final class LoginButton: SwissArmyButton {
	var loginButtonCell: LoginButtonCell { cell as! LoginButtonCell }

	var buttonState: LoginButtonState = .disabled {
		didSet {
			buttonStateChanged()
		}
	}

	var loadingImageView: NSImageView?

	func buttonStateChanged() {
		updateTitle()
		updateEnabled()
		updateImage()
		updateLoadingImageView()
	}

	func updateTitle() {
		title = buttonState.title()
	}

	func updateEnabled() {
		switch buttonState {
		case .disabled, .sending:
			isEnabled = false
		case .enabled, .error:
			isEnabled = true
		}
	}

	func updateImage() {
		image = buttonState.image()
	}

	func updateLoadingImageView() {
		switch buttonState {
		case .sending:
			setupLoadingImageView()
		default:
			destroyLoadingImageView()
		}
	}

	func setupLoadingImageView() {
		if loadingImageView == nil {
			let loaderImage = buttonState.image()
			let imageFrame = CGRect(x: 244.0, y: 8.0, width: 20.0, height: 20.0)
			loadingImageView = NSImageView(frame: imageFrame)
			loadingImageView!.image = loaderImage
			addSubview(loadingImageView!)
			Animations.rotateCounterClockwise(loadingImageView!)
		}
	}

	func destroyLoadingImageView() {
		if loadingImageView != nil {
			loadingImageView!.removeFromSuperview()
			loadingImageView = nil
		}
	}

	enum LoginButtonState {
		case disabled
		case enabled
		case sending
		case error(String)

		func title() -> String {
			switch self {
			case .disabled, .enabled:
				"Log in"
			case .sending:
				"Logging in..."
			case .error(let message):
				message
			}
		}

		func image() -> NSImage? {
			switch self {
			case .disabled, .enabled:
				NSImage(named: "Login-Next")
			case .sending:
				NSImage(named: "Loader-Login")
			case .error:
				NSImage(named: "Login-Error")
			}
		}
	}
}
