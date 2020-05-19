import Foundation
import Alamofire

extension Router {
	public enum Blogs: URLRequestConvertible {
		case index(params: Parameters?)
		case show(id: Int)
		case showTracks(id: Int, params: Parameters?)

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
				return "/blogs"
			case let .show(id):
				return "/blogs/\(id)"
			case let .showTracks(id, _):
				return "/blogs/\(id)/tracks"
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
