import Foundation
import Alamofire

extension Requests {
	public struct Misc {
		public static func getToken(
			usernameOrEmail: String,
			password: String,
			completionHandler: @escaping (DataResponse<UsernameAndToken>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Misc.getToken(usernameOrEmail: usernameOrEmail, password: password))
				.responseUsernameAndToken(completionHandler: completionHandler)
		}
	}
}

public struct UsernameAndToken {
	public let username: String
	public let token: String

	init(username: String, token: String) {
		self.username = username
		self.token = token
	}
}
