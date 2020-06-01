import Cocoa

extension String {
	func getSubstringBetweenPrefix(_ prefix: String, andSuffix suffix: String) -> String? {
		func getSubstringAfterPrefix() -> String? {
			if let prefixRange = self.range(of: prefix) {
				let substringRange = prefixRange.upperBound..<endIndex
				return substring(with: substringRange)
			} else {
				return nil
			}
		}

		func getSubstringBeforeSuffix(_ substring: String) -> String? {
			if let suffixRange = substring.range(of: suffix) {
				let substringRange = substring.startIndex..<suffixRange.lowerBound
				return substring.substring(with: substringRange)
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
