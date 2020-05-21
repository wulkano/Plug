import Cocoa
import HypeMachineAPI

final class SingleBlogViewFormatter: Formatter {
	var colorArt: SLColorArt!

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

	func formattedCount(_ count: NSNumber) -> NSAttributedString {
		let countString = LovedCountFormatter().string(for: count)!
		return NSAttributedString(string: countString, attributes: countAttributes())
	}

	func formattedLabel(_ text: String) -> NSAttributedString {
		NSAttributedString(string: text, attributes: labelAttributes())
	}

	func countAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = getCountColor()
		attributes[.font] = getFont()
		return attributes
	}

	func labelAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = getLabelColor()
		attributes[.font] = getFont()
		return attributes
	}

	func getCountColor() -> NSColor {
		if colorArt.primaryColor != nil {
			return colorArt.primaryColor
		} else if colorArt.secondaryColor != nil {
			return colorArt.secondaryColor
		} else if colorArt.detailColor != nil {
			return colorArt.detailColor
		} else {
			return NSColor.black
		}
	}

	func getLabelColor() -> NSColor {
		if colorArt.secondaryColor != nil {
			return colorArt.secondaryColor
		} else if colorArt.detailColor != nil {
			return colorArt.detailColor
		} else if colorArt.primaryColor != nil {
			return colorArt.primaryColor
		} else {
			return NSColor.black
		}
	}

	func getFont() -> NSFont {
		appFont(size: 13, weight: .medium)
	}
}
