import Foundation
import Alamofire

// MARK: ResponseObject

protocol ResponseObjectSerializable {
	init?(response: HTTPURLResponse, representation: Any)
}

extension DataRequest {
	func responseObject<T: ResponseObjectSerializable>(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<T>) -> Void
	)
		-> Self {
		let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
			if let error = error {
				return .failure(APIError.network(error: error))
			}

			let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)

			guard case let .success(jsonObject) = result else {
				return .failure(APIError.jsonSerialization(error: result.error!))
			}

			guard let response = response, let responseObject = T(response: response, representation: jsonObject) else {
				return .failure(APIError.objectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
			}

			return .success(responseObject)
		}

		return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}

// MARK: ResponseCollection

protocol ResponseCollectionSerializable {
	static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
	static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self] {
		var collection: [Self] = []

		if let representation = representation as? [[String: Any]] {
			for itemRepresentation in representation {
				if let item = Self(response: response, representation: itemRepresentation) {
					collection.append(item)
				}
			}
		}

		return collection
	}
}

extension DataRequest {
	@discardableResult
	func responseCollection<T: ResponseCollectionSerializable>(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<[T]>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
			if let error = error {
				return .failure(APIError.network(error: error))
			}

			let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = jsonSerializer.serializeResponse(request, response, data, nil)

			guard case let .success(jsonObject) = result else {
				return .failure(APIError.jsonSerialization(error: result.error!))
			}

			guard let response = response else {
				let reason = "Response collection could not be serialized due to nil response."
				return .failure(APIError.objectSerialization(reason: reason))
			}

			return .success(T.collection(from: response, withRepresentation: jsonObject))
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}

// MARK: ResponseBool

extension DataRequest {
	@discardableResult
	func responseBool(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<Bool>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<Bool> { request, response, data, error in
			if let error = error {
				return .failure(APIError.network(error: error))
			}

			let stringSerializer = DataRequest.stringResponseSerializer()
			let result = stringSerializer.serializeResponse(request, response, data, nil)

			guard case let .success(string) = result else {
				return .failure(APIError.stringSerialization(error: result.error!))
			}

			guard string == "0" || string == "1" else {
				let reason = "Expected a 0 or 1 in response but got something else."
				return .failure(APIError.objectSerialization(reason: reason))
			}

			let bool = string == "1"

			return .success(bool)
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}

// MARK: ResponseStringArray

extension DataRequest {
	@discardableResult
	func responseStringArray(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<[String]>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<[String]> { request, response, data, error in
			if let error = error {
				return .failure(APIError.network(error: error))
			}

			let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = jsonSerializer.serializeResponse(request, response, data, nil)

			guard case let .success(jsonObject) = result else {
				return .failure(APIError.jsonSerialization(error: result.error!))
			}

			guard let responseArray = jsonObject as? [String] else {
				let reason = "Expected an array of strings but got something else."
				return .failure(APIError.objectSerialization(reason: reason))
			}

			return .success(responseArray)
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}

// MARK: ResponseUsernameAndToken

extension DataRequest {
	@discardableResult
	func responseUsernameAndToken(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<UsernameAndToken>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<UsernameAndToken> { request, response, data, error in
			if let error = error {
				return .failure(APIError.network(error: error))
			}

			let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = jsonSerializer.serializeResponse(request, response, data, nil)

			guard case let .success(jsonObject) = result else {
				return .failure(APIError.jsonSerialization(error: result.error!))
			}

			guard
				let representation = jsonObject as? [String: Any],
				let username = representation["username"] as? String,
				let token = representation["hm_token"] as? String
			else {
				let reason = "No username or token found in response."
				return .failure(APIError.objectSerialization(reason: reason))
			}

			return .success(UsernameAndToken(username: username, token: token))
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}
