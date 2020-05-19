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
			case let .show(username):
				let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
				return "/users/\(escapedUsername)"
			case let .showFavorites(username, _):
				let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
				return "/users/\(escapedUsername)/favorites"
			case let .showFriends(username, _):
				let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
				return "/users/\(escapedUsername)/friends"
			}
		}

		var params: Parameters? {
			switch self {
			case .show:
				return nil
			case let .showFavorites(_, optionalParams):
				return optionalParams
			case let .showFriends(_, optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
