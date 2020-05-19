import Foundation
import Alamofire

public struct Requests {
	public static func defaultRequest(_ urlRequest: URLRequestConvertible) -> Alamofire.DataRequest {
		Alamofire
			.request(urlRequest)
			.validate()
			.validate(Validations.apiErrorValidation)
	}
}
