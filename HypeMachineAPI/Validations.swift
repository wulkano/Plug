import Foundation
import Alamofire

public enum Validations {
	public static let apiErrorValidation: Alamofire.DataRequest.Validation = { _, _, data in
		guard
			let data = data,
			let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
			let representation = object as? [String: Any],
			let errorMessage = representation["error_msg"] as? String
		else {
			return .success
		}

		switch errorMessage {
		case "Must provide valid hm_token":
			return .failure(APIError.invalidHMToken)
		case "Wrong password":
			return .failure(APIError.incorrectPassword)
		case "Wrong username":
			return .failure(APIError.incorrectUsername)
		default:
			return .failure(APIError.unknownError(message: errorMessage))
		}
	}
}
