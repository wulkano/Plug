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
			case .show(let name):
				let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
				return "/artists/\(escapedName)"
			case .showTracks(let name, _):
				let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
				return "/artists/\(escapedName)/tracks"
			}
		}

		var params: Parameters? {
			switch self {
			case .index(let optionalParams):
				return optionalParams
			case .show:
				return nil
			case .showTracks(_, let optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
