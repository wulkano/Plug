import Foundation
import Alamofire

extension Router {
	public enum Users: URLRequestConvertible {
		case show(username: String)
		case showFavorites(username: String, params: Parameters?)
		case showFriends(username: String, params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .show:
				return .get
			case .showFavorites:
				return .get
			case .showFriends:
				return .get
			}
		}

		var path: String {
			switch self {
			case .show(let username):
				let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
				return "/users/\(escapedUsername)"
			case .showFavorites(let username, _):
				let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
				return "/users/\(escapedUsername)/favorites"
			case .showFriends(let username, _):
				let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
				return "/users/\(escapedUsername)/friends"
			}
		}

		var params: Parameters? {
			switch self {
			case .show:
				return nil
			case .showFavorites(_, let optionalParams):
				return optionalParams
			case .showFriends(_, let optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
