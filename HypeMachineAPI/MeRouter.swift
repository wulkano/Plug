import Foundation
import Alamofire

extension Router {
	public enum Me: URLRequestConvertible {
		case favorites(params: Parameters?)
		case toggleTrackFavorite(id: String, params: Parameters?)
		case toggleBlogFavorite(id: Int, params: Parameters?)
		case toggleUserFavorite(id: String, params: Parameters?)
		case playlistNames
		case showPlaylist(id: Int, params: Parameters?)
		case postHistory(id: String, position: Int, params: Parameters?)
		case friends(params: Parameters?)
		case feed(params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .favorites:
				.get
			case .toggleTrackFavorite:
				.post
			case .toggleBlogFavorite:
				.post
			case .toggleUserFavorite:
				.post
			case .playlistNames:
				.get
			case .showPlaylist:
				.get
			case .postHistory:
				.post
			case .friends:
				.get
			case .feed:
				.get
			}
		}

		var path: String {
			switch self {
			case .favorites:
				"/me/favorites"
			case .toggleTrackFavorite:
				"/me/favorites"
			case .toggleBlogFavorite:
				"/me/favorites"
			case .toggleUserFavorite:
				"/me/favorites"
			case .playlistNames:
				"/me/playlist_names"
			case .showPlaylist(let id, _):
				"/me/playlists/\(id)"
			case .postHistory:
				"/me/history"
			case .friends:
				"/me/friends"
			case .feed:
				"/me/feed"
			}
		}

		var params: Parameters? {
			switch self {
			case .favorites(let optionalParams):
				optionalParams
			case .toggleTrackFavorite(let id, let optionalParams):
				["val": id, "type": "item"].merge(optionalParams)
			case .toggleBlogFavorite(let id, let optionalParams):
				["val": id, "type": "site"].merge(optionalParams)
			case .toggleUserFavorite(let id, let optionalParams):
				["val": id, "type": "user"].merge(optionalParams)
			case .playlistNames:
				nil
			case .showPlaylist(_, let optionalParams):
				optionalParams
			case .postHistory(let id, let position, let optionalParams):
				["type": "listen", "itemid": id, "pos": position].merge(optionalParams)
			case .friends(let optionalParams):
				optionalParams
			case .feed(let optionalParams):
				optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}
