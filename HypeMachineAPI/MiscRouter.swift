import Foundation
import Alamofire
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

// TODO: Replace this with CryptoKit when targeting macOS 10.15.
func MD5(string: String) -> Data {
	let length = Int(CC_MD5_DIGEST_LENGTH)
	let messageData = string.data(using: .utf8)!
	var digestData = Data(count: length)

	_ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
		messageData.withUnsafeBytes { messageBytes -> UInt8 in
			if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
				let messageLength = CC_LONG(messageData.count)
				CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
			}

			return 0
		}
	}

	return digestData
}

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
			return MD5(string: serialNumber).map { String(format: "%02hhx", $0) }.joined()
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
