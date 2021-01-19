import Foundation
import Alamofire

public enum Router {
	static let baseURLString = "https://api.hypem.com/v2"

	static func generateURLRequest(method: HTTPMethod, path: String, params: Parameters?) throws -> URLRequest {
		// Probably a bug in the hype machine API, but hm_token must be part of the path, can't be form encoded
		var urlString = baseURLString + path
		if hmToken != nil {
			urlString += "?hm_token=\(hmToken!)"
		}
		let URL = try urlString.asURL()
		var urlRequest = URLRequest(url: URL)
		urlRequest.httpMethod = method.rawValue

		if userAgent != nil {
			urlRequest.addValue(userAgent!, forHTTPHeaderField: "User-Agent")
		}

		let mergedParams = addApiKeyParam(params ?? [:])

		return try URLEncoding.default.encode(urlRequest, with: mergedParams)
	}

	static func addApiKeyParam(_ params: Parameters) -> Parameters {
		guard let apiKey = apiKey else {
			return params
		}

		return ["key": apiKey].merge(params)
	}
}
