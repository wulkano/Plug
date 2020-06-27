import Foundation
import Alamofire

let clientID = "2c3c67194673f9968b7c8b5f2b50d486"

extension DataRequest {
	@discardableResult
	fileprivate func responseSoundcloudURL(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<URL>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<URL> { request, response, data, error in
			guard error == nil else {
				return .failure(SoundCloudAPI.Errors.cantParseResponse)
			}

			let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = jsonSerializer.serializeResponse(request, response, data, nil)

			guard case .success(let jsonObject) = result else {
				return .failure(SoundCloudAPI.Errors.cantParseResponse)
			}

			guard
				let representation = jsonObject as? [String: Any],
				let urlString = representation["permalink_url"] as? String,
				let url = URL(string: urlString)
			else {
				return .failure(SoundCloudAPI.Errors.cantParseResponse)
			}

			return .success(url)
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}

struct SoundCloudAPI {
	struct Tracks {
		@discardableResult
		static func permalink(_ trackId: String, completionHandler: @escaping (DataResponse<URL>) -> Void) -> DataRequest {
			let url = "https://api.soundcloud.com/tracks/\(trackId).json"

			return Alamofire.request(url, method: .get, parameters: ["client_id": clientID])
				.validate()
				.responseSoundcloudURL(completionHandler: completionHandler)
		}
	}

	enum Errors: Error {
		case cantParseResponse
	}
}
