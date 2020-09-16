import Cocoa
import HypeMachineAPI

final class BlogTableCellView: IOSStyleTableCellView {
	var nameTextField: NSTextField!
	var recentArtistsTextField: NSTextField!

	override var objectValue: Any! {
		didSet {
			objectValueChanged()
		}
	}

	var blog: HypeMachineAPI.Blog { objectValue as! HypeMachineAPI.Blog }

	func objectValueChanged() {
		guard objectValue != nil else {
			return
		}

		updateName()
		updateArtists()
	}

	func updateName() {
		nameTextField.stringValue = blog.name
	}

	func updateArtists() {
		let originalBlogID = blog.id
		recentArtistsTextField.stringValue = "Loading…"

		let parameters = [
			"page": 1,
			"count": 3
		]

		HypeMachineAPI.Requests.Blogs.showTracks(id: blog.id, params: parameters) { [weak self] response in
			guard
				let self = self,
				self.objectValue != nil,
				self.blog.id == originalBlogID
			else {
				return
			}

			switch response.result {
			case .success(let tracks):
				var recentTracks = ""
				for (index, track) in tracks.enumerated() {
					recentTracks += "\(track.artist)"

					if index < tracks.count - 1 {
						recentTracks += ", "
					}
				}

				self.recentArtistsTextField.stringValue = recentTracks
			case .failure(let error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
			}
		}
	}
}
