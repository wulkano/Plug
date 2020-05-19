import Cocoa

extension String {
	func stringByAddingPercentEncodingForURLQueryValue() -> String? {
		let characterSet = NSMutableCharacterSet.alphanumeric()
		characterSet.addCharacters(in: "-._~:/")

		return addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
	}
}
