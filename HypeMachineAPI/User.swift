import Cocoa

// swiftlint:disable discouraged_optional_boolean

public struct User {
	public let username: String
	public let fullName: String?
	public let avatarURL: URL?
	public let favoritesCount: Int
	public let followersCount: Int
	public let followingCount: Int
	public var friend: Bool?
	public var follower: Bool?

	public init(
		username: String,
		fullName: String,
		avatarURL: URL?,
		favoritesCount: Int,
		followersCount: Int,
		followingCount: Int,
		friend: Bool?,
		follower: Bool?
	) {
		self.username = username
		self.fullName = fullName
		self.avatarURL = avatarURL
		self.favoritesCount = favoritesCount
		self.followersCount = followersCount
		self.followingCount = followingCount
		self.friend = friend
		self.follower = follower
	}

	public var favoritesCountNum: NSNumber {
		NSNumber(value: favoritesCount)
	}

	public var followersCountNum: NSNumber {
		NSNumber(value: followersCount)
	}

	public var followingCountNum: NSNumber {
		NSNumber(value: followingCount)
	}
}

extension User: CustomStringConvertible {
	public var description: String {
		"User: { username: \(username), fullName: \(fullName ?? "") }"
	}
}

extension User: ResponseObjectSerializable, ResponseCollectionSerializable {
	public init?(response: HTTPURLResponse, representation: Any) {
		guard
			let representation = representation as? [String: Any],
			let username = representation["username"] as? String,
			let favoritesCountInfo = representation["favorites_count"] as? NSDictionary
		else {
			return nil
		}

		func nonEmptyStringForJSONKey(_ key: String) -> String? {
			guard let string = representation["key"] as? String else {
				return nil
			}

			return string.isEmpty ? nil : string
		}

		func urlForJSONKey(_ key: String) -> URL? {
			guard let urlString = representation[key] as? String else {
				return nil
			}

			return URL(string: urlString)
		}

		self.username = username
		self.fullName = nonEmptyStringForJSONKey("fullname")
		self.avatarURL = urlForJSONKey("userpic")
		self.favoritesCount = favoritesCountInfo["item"] as? Int ?? 0
		self.followersCount = favoritesCountInfo["followers"] as? Int ?? 0
		self.followingCount = favoritesCountInfo["user"] as? Int ?? 0
		self.friend = representation["is_friend"] as? Bool
		self.follower = representation["is_follower"] as? Bool
	}
}


extension User: Equatable {
	public static func == (lhs: User, rhs: User) -> Bool {
		lhs.username == rhs.username
	}
}

extension User: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(username)
	}
}

// swiftlint:enable discouraged_optional_boolean
