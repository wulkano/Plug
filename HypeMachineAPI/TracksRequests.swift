import Foundation
import Alamofire

extension Requests {
	public enum Tracks {
		@discardableResult
		public static func index(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Tracks.index(params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		@discardableResult
		public static func show(
			id: String,
			completionHandler: @escaping (DataResponse<Track>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Tracks.show(id: id))
				.responseObject(completionHandler: completionHandler)
		}

		@discardableResult
		public static func popular(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Tracks.popular(params: params))
				.responseCollection(completionHandler: completionHandler)
		}
	}
}
