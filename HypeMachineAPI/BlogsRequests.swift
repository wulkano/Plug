import Foundation
import Alamofire

extension Requests {
	public struct Blogs {
		@discardableResult
		public static func index(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Blog]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Blogs.index(params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		@discardableResult
		public static func show(
			id: Int,
			completionHandler: @escaping (DataResponse<Blog>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Blogs.show(id: id))
				.responseObject(completionHandler: completionHandler)
		}

		@discardableResult
		public static func showTracks(
			id: Int,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Blogs.showTracks(id: id, params: params))
				.responseCollection(completionHandler: completionHandler)
		}
	}
}
