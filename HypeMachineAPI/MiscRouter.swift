import Foundation
import Alamofire
import CryptoSwift

extension Router {
	public enum Misc: URLRequestConvertible {
		case getToken(usernameOrEmail: String, password: String)

		var method: HTTPMethod {
			switch self {
			case .getToken:
				return .post
			}
		}

		var path: String {
			switch self {
			case .getToken:
				return "/get_token"
			}
		}

		var params: Parameters? {
			switch self {
			case let .getToken(usernameOrEmail, password):
				return [
					"username": usernameOrEmail as AnyObject,
					"password": password as AnyObject,
					"device_id": deviceID() as AnyObject
				]
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}

		func deviceID() -> String {
			let serialNumber = getSerialNumber()!
			let hashedSerialNumber = serialNumber.md5()
			print(hashedSerialNumber)
			return hashedSerialNumber
		}

		func getSerialNumber() -> String? {
			var serial: String?
			var platformExpert: io_service_t?

			platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

			if platformExpert != nil {
				serial = IORegistryEntryCreateCFProperty(platformExpert!, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? String
				IOObjectRelease(platformExpert!)
			}

			return serial
		}
	}
}
