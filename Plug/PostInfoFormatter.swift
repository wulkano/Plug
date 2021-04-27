import Cocoa
import HypeMachineAPI

final class PostInfoFormatter: Formatter {
	func attributedStringForPostInfo(_ track: HypeMachineAPI.Track) -> NSAttributedString {
		let postInfoAttributedString = NSMutableAttributedString()
		let formattedBlogName = attributedBlogName(track.postedBy)
		let formattedDescription = attributedDescription(track.postedByDescription)
		let formattedDatePosted = attributedDatePosted(track.datePosted, url: track.hypeMachineURL())
		postInfoAttributedString.append(formattedBlogName)
		postInfoAttributedString.append(formattedDescription)
		postInfoAttributedString.append(formattedDatePosted)
		return postInfoAttributedString
	}

	private func attributedBlogName(_ blogName: String) -> NSAttributedString {
		NSAttributedString(string: blogName, attributes: boldAttributes())
	}

	private func attributedDescription(_ description: String) -> NSAttributedString {
		let string = "  “\(description)...”  "
		return NSAttributedString(string: string, attributes: normalAttributes())
	}

	private func attributedDatePosted(_ datePosted: Date, url: URL) -> NSAttributedString {
		let string = formattedDatePosted(datePosted)
		var dateAttributes = boldAttributes()
		dateAttributes[.link] = url.absoluteString as AnyObject?
		return NSAttributedString(string: string, attributes: dateAttributes)
	}

	private func formattedDatePosted(_ datePosted: Date) -> String {
		let formatter = DateFormatter()
		formatter.locale = .current

		if dateFromCurrentYear(datePosted) {
			formatter.dateFormat = "MMM d"
		} else {
			formatter.dateFormat = "MMM d yyyy"
		}

		return formatter.string(from: datePosted) + " →"
	}

	private func dateFromCurrentYear(_ date: Date) -> Bool {
		let dateComponents = (Calendar.current as NSCalendar).components(.year, from: date)
		let todayComponents = (Calendar.current as NSCalendar).components(.year, from: Date())
		return dateComponents.year == todayComponents.year
	}

	private func normalAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.white.withAlphaComponent(0.5)
		attributes[.font] = appFont(size: 13)
		return attributes
	}

	private func boldAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.white
		attributes[.font] = appFont(size: 13, weight: .medium)
		return attributes
	}
}
