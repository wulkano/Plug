import Foundation
import Alamofire

extension Requests {
	public struct Me {
		public static func favorites(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.favorites(params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		public static func toggleTrackFavorite(
			id: String,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<Bool>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.toggleTrackFavorite(id: id, params: params))
				.responseBool(completionHandler: completionHandler)
		}

		public static func toggleBlogFavorite(
			id: Int,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<Bool>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.toggleBlogFavorite(id: id, params: params))
				.responseBool(completionHandler: completionHandler)
		}

		public static func toggleUserFavorite(
			id: String,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<Bool>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.toggleUserFavorite(id: id, params: params))
				.responseBool(completionHandler: completionHandler)
		}

		public static func playlistNames(
			_ completionHandler: @escaping (DataResponse<[String]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.playlistNames)
				.responseStringArray(completionHandler: completionHandler)
		}

		// Playlist id's are 1...3
		public static func showPlaylist(
			id: Int,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.showPlaylist(id: id, params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		public static func postHistory(
			id: String,
			position: Int,
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<String>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.postHistory(id: id, position: position, params: params))
				.responseString(completionHandler: completionHandler)
		}

		public static func friends(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[User]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.friends(params: params))
				.responseCollection(completionHandler: completionHandler)
		}

		public static func feed(
			params: Parameters? = nil,
			completionHandler: @escaping (DataResponse<[Track]>) -> Void
		) -> DataRequest {
			Requests
				.defaultRequest(Router.Me.feed(params: params))
				.responseCollection(completionHandler: completionHandler)
		}
	}
}
