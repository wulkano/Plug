import Cocoa

public struct Blog {
	public let id: Int
	public let name: String
	public let url: URL
	public let followerCount: Int
	public let trackCount: Int
	public let imageURL: URL
	public let imageURLSmall: URL
	public let featured: Bool
	public let following: Bool

	public init(
		id: Int,
		name: String,
		url: URL,
		followerCount: Int,
		trackCount: Int,
		imageURL: URL,
		imageURLSmall: URL,
		featured: Bool,
		following: Bool
	) {
		self.id = id
		self.name = name
		self.url = url
		self.followerCount = followerCount
		self.trackCount = trackCount
		self.imageURL = imageURL
		self.imageURLSmall = imageURLSmall
		self.featured = featured
		self.following = following
	}

	public var followerCountNum: NSNumber {
		NSNumber(value: followerCount)
	}

	public var trackCountNum: NSNumber {
		NSNumber(value: trackCount)
	}

	public func imageURL(size: ImageSize) -> URL {
		switch size {
		case .normal:
			return imageURL
		case .small:
			return imageURLSmall
		}
	}

	public enum ImageSize {
		case normal
		case small
	}
}

extension Blog: CustomStringConvertible {
	public var description: String {
		"Blog: { name: \(name) }"
	}
}

extension Blog: ResponseObjectSerializable, ResponseCollectionSerializable {
	public init?(response: HTTPURLResponse, representation: Any) {
		guard
			let representation = representation as? [String: Any],
			let id = representation["siteid"] as? Int,
			let name = representation["sitename"] as? String,
			let urlString = representation["siteurl"] as? String,
			let url = URL(string: urlString.replacingOccurrences(of: " ", with: "")),
			let followerCount = representation["followers"] as? Int,
			let trackCount = representation["total_tracks"] as? Int,
			let imageURLString = representation["blog_image"] as? String,
			let imageURL = URL(string: imageURLString),
			let imageURLSmallString = representation["blog_image_small"] as? String,
			let imageURLSmall = URL(string: imageURLSmallString)
		else {
			return nil
		}

		self.id = id
		self.name = name
		self.url = url
		self.followerCount = followerCount
		self.trackCount = trackCount
		self.imageURL = imageURL
		self.imageURLSmall = imageURLSmall
		self.featured = representation["ts_featured"] is Int
		self.following = representation["ts_loved_me"] is Int
	}
}

extension Blog: Equatable {
	public static func == (lhs: Blog, rhs: Blog) -> Bool {
		lhs.id == rhs.id
	}
}

extension Blog: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
