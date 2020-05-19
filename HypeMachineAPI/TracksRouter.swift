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
			case let .show(id):
				return "/tracks/\(id)"
			case .popular:
				return "/popular"
			}
		}

		var params: Parameters? {
			switch self {
			case let .index(optionalParams):
				return optionalParams
			case .show:
				return nil
			case let .popular(optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
