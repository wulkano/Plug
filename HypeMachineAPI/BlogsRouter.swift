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
				.get
			case .show:
				.get
			case .showTracks:
				.get
			}
		}

		var path: String {
			switch self {
			case .index:
				"/blogs"
			case .show(let id):
				"/blogs/\(id)"
			case .showTracks(let id, _):
				"/blogs/\(id)/tracks"
			}
		}

		var params: Parameters? {
			switch self {
			case .index(let optionalParams):
				optionalParams
			case .show:
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
