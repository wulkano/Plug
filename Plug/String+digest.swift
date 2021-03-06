import Foundation
import CommonCrypto.CommonHMAC

// TODO: Replace this with CryptoKit when targeting macOS 10.15.

enum HMACAlgorithm {
	case md5
	case sha1
	case sha224
	case sha256
	case sha384
	case sha512

	func toCCEnum() -> CCHmacAlgorithm {
		var result = 0
		switch self {
		case .md5:
			result = kCCHmacAlgMD5
		case .sha1:
			result = kCCHmacAlgSHA1
		case .sha224:
			result = kCCHmacAlgSHA224
		case .sha256:
			result = kCCHmacAlgSHA256
		case .sha384:
			result = kCCHmacAlgSHA384
		case .sha512:
			result = kCCHmacAlgSHA512
		}

		return CCHmacAlgorithm(result)
	}

	func digestLength() -> Int {
		var result: CInt = 0
		switch self {
		case .md5:
			result = CC_MD5_DIGEST_LENGTH
		case .sha1:
			result = CC_SHA1_DIGEST_LENGTH
		case .sha224:
			result = CC_SHA224_DIGEST_LENGTH
		case .sha256:
			result = CC_SHA256_DIGEST_LENGTH
		case .sha384:
			result = CC_SHA384_DIGEST_LENGTH
		case .sha512:
			result = CC_SHA512_DIGEST_LENGTH
		}

		return Int(result)
	}
}

extension String {
	func digest(_ algorithm: HMACAlgorithm, key: String) -> String! {
		let string = cString(using: .utf8)
		let stringLength = Int(lengthOfBytes(using: .utf8))
		let digestLength = algorithm.digestLength()
		let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
		let keyString = key.cString(using: .utf8)
		let keyLength = Int(key.lengthOfBytes(using: .utf8))

		CCHmac(algorithm.toCCEnum(), keyString!, keyLength, string!, stringLength, result)

		let hash = NSMutableString()
		for index in 0..<digestLength {
			hash.appendFormat("%02x", result[index])
		}

		// FIXME: Error: `'deinitialize()' is unavailable: the default argument to deinitialize(count:) has been removed, please specify the count explicitly`
		// result.deinitialize()

		return String(hash)
	}
}
