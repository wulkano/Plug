import Cocoa

public struct Artist {
	public let name: String
	public let thumbURL: URL?
	public let cnt: Int?
	public let rank: Int?

	public init(name: String, thumbURL: URL?, cnt: Int?, rank: Int?) {
		self.name = name
		self.thumbURL = thumbURL
		self.cnt = cnt
		self.rank = rank
	}
}

extension Artist: CustomStringConvertible {
	public var description: String {
		"Artist: { name: \(name) }"
	}
}

extension Artist: ResponseObjectSerializable, ResponseCollectionSerializable {
	public init?(response: HTTPURLResponse, representation: Any) {
		guard
			let representation = representation as? [String: Any],
			let name = representation["artist"] as? String
		else { return nil }

		func urlForJSONKey(_ key: String) -> URL? {
			guard let urlString = representation[key] as? String else {
				return nil
			}
			return URL(string: urlString)
		}

		self.name = name
		self.thumbURL = urlForJSONKey("thumb_url_artist")
		self.cnt = representation["cnt"] as? Int
		self.rank = representation["rank"] as? Int
	}
}

extension Artist: Equatable {
	public static func == (lhs: Artist, rhs: Artist) -> Bool {
		lhs.name == rhs.name
	}
}

extension Artist: Hashable {
	public var hashValue: Int {
		name.hashValue
	}
}
