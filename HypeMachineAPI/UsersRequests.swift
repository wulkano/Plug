import Foundation
import Alamofire

extension Requests {
	public struct Users {
		public static func show(
			username: String,
			completionHandler: @escaping (DataResponse<User>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Users.show(username: username))
				.responseObject(completionHandler: completionHandler)
		}

		public static func showFavorites(
			username: String,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Users.showFavorites(username: username, params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		public static func showFriends(
			username: String,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[User]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Users.showFriends(username: username, params: params))
				.responseCollection(completionHandler: completionHandler)
		}
	}
}
