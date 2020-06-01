import Cocoa

public struct Tag {
	public let name: String
	public let priority: Bool

	public init(name: String, priority: Bool) {
		self.name = name
		self.priority = priority
	}
}

extension Tag: CustomStringConvertible {
	public var description: String {
		"Tag: { name: \(name), priority: \(priority) }"
	}
}

extension Tag: ResponseObjectSerializable, ResponseCollectionSerializable {
	public init?(response: HTTPURLResponse, representation: Any) {
		guard
			let representation = representation as? [String: Any],
			let name = representation["tag_name"] as? String
		else {
			return nil
		}

		self.name = name
		self.priority = representation["priority"] as? Bool ?? false
	}
}

extension Tag: Equatable {
	public static func == (lhs: Tag, rhs: Tag) -> Bool {
		lhs.name == rhs.name
	}
}

extension Tag: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
