import Cocoa
import HypeMachineAPI

final class SingleBlogViewFormatter: Formatter {
	private let font = appFont(size: 13, weight: .medium)
	private var colorArt: SLColorArt!

	func attributedBlogDetails(_ blog: HypeMachineAPI.Blog, colorArt: SLColorArt) -> NSAttributedString {
		self.colorArt = colorArt

		let formattedFollowersCount = formattedCount(blog.followerCountNum)
		let formattedFollowersLabel = formattedLabel(" Followers  ")
		let formattedTracksCount = formattedCount(blog.trackCountNum)
		let formattedTracksLabel = formattedLabel(" Tracks")

		let blogDetails = NSMutableAttributedString()
		blogDetails.append(formattedFollowersCount)
		blogDetails.append(formattedFollowersLabel)
		blogDetails.append(formattedTracksCount)
		blogDetails.append(formattedTracksLabel)

		return blogDetails
	}

	private func formattedCount(_ count: NSNumber) -> NSAttributedString {
		let countString = LovedCountFormatter().string(for: count)!
		return NSAttributedString(string: countString, attributes: countAttributes)
	}

	private func formattedLabel(_ text: String) -> NSAttributedString {
		NSAttributedString(string: text, attributes: labelAttributes)
	}

	private var countAttributes: [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.labelColor
		attributes[.font] = font
		return attributes
	}

	private var labelAttributes: [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.secondaryLabelColor
		attributes[.font] = font
		return attributes
	}
}
