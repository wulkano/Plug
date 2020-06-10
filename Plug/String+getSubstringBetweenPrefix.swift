import Cocoa

extension String {
	func getSubstringBetweenPrefix(_ prefix: String, andSuffix suffix: String) -> String? {
		func getSubstringAfterPrefix() -> String? {
			if let prefixRange = self.range(of: prefix) {
				return String(self[prefixRange.upperBound..<endIndex])
			} else {
				return nil
			}
		}

		func getSubstringBeforeSuffix(_ substring: String) -> String? {
			if let suffixRange = substring.range(of: suffix) {
				return String(substring[substring.startIndex..<suffixRange.lowerBound])
			} else {
				return nil
			}
		}

		if let substringWithoutPrefix = getSubstringAfterPrefix() {
			return getSubstringBeforeSuffix(substringWithoutPrefix)
		}

		return nil
	}
}
