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
		attributes[.foregroundColor] = countColor
		attributes[.font] = font
		return attributes
	}

	private var labelAttributes: [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = labelColor
		attributes[.font] = font
		return attributes
	}

	private var countColor: NSColor {
		if let primaryColor = colorArt.primaryColor {
			return primaryColor
		} else if let secondaryColor = colorArt.secondaryColor {
			return secondaryColor
		} else if let detailColor = colorArt.detailColor {
			return detailColor
		} else {
			return .black
		}
	}

	private var labelColor: NSColor {
		if colorArt.secondaryColor != nil {
			return colorArt.secondaryColor
		} else if colorArt.detailColor != nil {
			return colorArt.detailColor
		} else if colorArt.primaryColor != nil {
			return colorArt.primaryColor
		} else {
			return .black
		}
	}
}
