import Cocoa

extension String {
	func getSubstringBetweenPrefix(_ prefix: String, andSuffix suffix: String) -> String? {
		func getSubstringAfterPrefix() -> String? {
			if let prefixRange = range(of: prefix) {
				return String(self[prefixRange.upperBound..<endIndex])
			}

			return nil
		}

		func getSubstringBeforeSuffix(_ substring: String) -> String? {
			if let suffixRange = substring.range(of: suffix) {
				return String(substring[substring.startIndex..<suffixRange.lowerBound])
			}

			return nil
		}

		if let substringWithoutPrefix = getSubstringAfterPrefix() {
			return getSubstringBeforeSuffix(substringWithoutPrefix)
		}

		return nil
	}
}
