import Foundation
import Alamofire

extension Router {
	public enum Tags: URLRequestConvertible {
		case index
		case showTracks(name: String, params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .index:
				.get
			case .showTracks:
				.get
			}
		}

		var path: String {
			switch self {
			case .index:
				return "/tags"
			case .showTracks(let name, _):
				let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
				return "/tags/\(escapedName)/tracks"
			}
		}

		var params: Parameters? {
			switch self {
			case .index:
				nil
			case .showTracks(_, let optionalParams):
				optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
