import Foundation
import Alamofire

public enum Requests {
	public static func defaultRequest(_ urlRequest: URLRequestConvertible) -> Alamofire.DataRequest {
		Alamofire
			.request(urlRequest)
			.validate(Validations.apiErrorValidation)
	}
}
