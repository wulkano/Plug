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
				.get
			case .show:
				.get
			case .popular:
				.get
			}
		}

		var path: String {
			switch self {
			case .index:
				"/tracks"
			case .show(let id):
				"/tracks/\(id)"
			case .popular:
				"/popular"
			}
		}

		var params: Parameters? {
			switch self {
			case .index(let optionalParams):
				optionalParams
			case .show:
				nil
			case .popular(let optionalParams):
				optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
