import Foundation
import Alamofire

extension Requests {
	public enum Artists {
		@discardableResult
		public static func index(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Artist]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Artists.index(params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		@discardableResult
		public static func show(
			name: String,
			completionHandler: @escaping (DataResponse<Artist>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Artists.show(id: name))
				.responseObject(completionHandler: completionHandler)
		}

		@discardableResult
		public static func showTracks(
			name: String,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Artists.showTracks(name: name, params: params))
				.responseCollection(completionHandler: completionHandler)
		}
	}
}
