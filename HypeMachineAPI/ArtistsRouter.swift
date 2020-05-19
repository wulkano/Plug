import Foundation
import Alamofire

extension Router {
	public enum Artists: URLRequestConvertible {
		case index(params: Parameters?)
		case show(id: String)
		case showTracks(name: String, params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .index:
				return .get
			case .show:
				return .get
			case .showTracks:
				return .get
			}
		}

		var path: String {
			switch self {
			case .index:
				return "/artists"
			case let .show(name):
				let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
				return "/artists/\(escapedName)"
			case let .showTracks(name, _):
				let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
				return "/artists/\(escapedName)/tracks"
			}
		}

		var params: Parameters? {
			switch self {
			case let .index(optionalParams):
				return optionalParams
			case .show:
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
