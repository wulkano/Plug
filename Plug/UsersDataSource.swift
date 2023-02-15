import Cocoa
import HypeMachineAPI

final class UsersDataSource: SearchableDataSource {
	func filterUsersMatchingSearchKeywords(_ users: [HypeMachineAPI.User]) -> [HypeMachineAPI.User] {
		users.filter { user in
			if user.fullName != nil {
				(user.username =~ searchKeywords!) || (user.fullName! =~ searchKeywords!)
			} else {
				user.username =~ searchKeywords!
			}
		}
	}

	func sortUsers(_ users: [HypeMachineAPI.User]) -> [HypeMachineAPI.User] {
		users.sorted { $0.username.lowercased() < $1.username.lowercased() }
	}

	// MARK: SearchableDataSource

	override func filterObjectsMatchingSearchKeywords(_ objects: [Any]) -> [Any] {
		let users = objects as! [HypeMachineAPI.User]
		return filterUsersMatchingSearchKeywords(users)
	}

	// MARK: HypeMachineDataSource

	override var singlePage: Bool { true }

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Me.friends { [weak self] response in
			guard let self else {
				return
			}

			nextPageResponseReceived(response)
		}
	}

	override func appendTableContents(_ contents: [Any]) {
		let users = contents as! [HypeMachineAPI.User]
		let sortedUsers = sortUsers(users)
		super.appendTableContents(sortedUsers)
	}
}
