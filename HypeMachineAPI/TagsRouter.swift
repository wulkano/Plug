import Foundation
import Alamofire

extension Router {
	public enum Tags: URLRequestConvertible {
		case index
		case showTracks(name: String, params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .index:
				return .get
			case .showTracks:
				return .get
			}
		}

		var path: String {
			switch self {
			case .index:
				return "/tags"
			case let .showTracks(name, _):
				let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
				return "/tags/\(escapedName)/tracks"
			}
		}

		var params: Parameters? {
			switch self {
			case .index:
				return nil
			case let .showTracks(_, optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
