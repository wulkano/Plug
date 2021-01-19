import Foundation
import Alamofire

extension Requests {
	public enum Tags {
		@discardableResult
		public static func index(
			_ completionHandler: @escaping (DataResponse<[Tag]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Tags.index)
				.responseCollection(completionHandler: completionHandler)
		}

		@discardableResult
		public static func showTracks(
			name: String,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Tags.showTracks(name: name, params: params))
				.responseCollection(completionHandler: completionHandler)
		}
	}
}
