import Cocoa
import HypeMachineAPI
import Alamofire

class UserTableCellView: IOSStyleTableCellView {
	var avatarView: NSImageView!
	var fullNameTextField: NSTextField!
	var usernameTextField: NSTextField!

	override var objectValue: Any! {
		didSet {
			objectValueChanged()
		}
	}

	var user: HypeMachineAPI.User { objectValue as! HypeMachineAPI.User }

	func objectValueChanged() {
		guard objectValue != nil else {
			return
		}

		updateFullName()
		updateUsername()
		updateImage()
	}

	func updateFullName() {
		fullNameTextField.stringValue = user.fullName ?? user.username
	}

	func updateUsername() {
		usernameTextField.stringValue = user.username
	}

	func updateImage() {
		avatarView.image = NSImage(named: "Avatar-Placeholder")

		guard let avatarURL = user.avatarURL else {
			return
		}

		Alamofire
			.request(avatarURL, method: .get)
			.validate()
			.responseImage { [weak self] response in
				guard let self = self else {
					return
				}

				switch response.result {
				case .success(let image):
					self.avatarView.image = image
				case .failure(let error):
					Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
					print(error)
				}
			}
	}
}
