//
//	String+.swift
//	Plug
//
//	Created by Alex Marchant on 9/10/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation


enum HMACAlgorithm {
	case md5, sha1, sha224, sha256, sha384, sha512

	func toCCEnum() -> CCHmacAlgorithm {
		var result: Int = 0
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
		let str = cString(using: String.Encoding.utf8)
		let strLen = Int(lengthOfBytes(using: String.Encoding.utf8))
		let digestLen = algorithm.digestLength()
		let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
		let keyStr = key.cString(using: String.Encoding.utf8)
		let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))

		CCHmac(algorithm.toCCEnum(), keyStr!, keyLen, str!, strLen, result)

		let hash = NSMutableString()
		for index in 0..<digestLen {
			hash.appendFormat("%02x", result[index])
		}

		// FIXME: Error: `'deinitialize()' is unavailable: the default argument to deinitialize(count:) has been removed, please specify the count explicitly`
		// result.deinitialize()

		return String(hash)
	}
}
