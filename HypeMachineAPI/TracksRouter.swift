import Foundation
import Alamofire

extension Router {
	public enum Tracks: URLRequestConvertible {
		case index(params: Parameters?)
		case show(id: String)
		case popular(params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .index:
				return .get
			case .show:
				return .get
			case .popular:
				return .get
			}
		}

		var path: String {
			switch self {
			case .index:
				return "/tracks"
			case .show(let id):
				return "/tracks/\(id)"
			case .popular:
				return "/popular"
			}
		}

		var params: Parameters? {
			switch self {
			case .index(let optionalParams):
				return optionalParams
			case .show:
				return nil
			case .popular(let optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
