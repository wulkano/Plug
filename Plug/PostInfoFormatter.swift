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

	fileprivate func attributedBlogName(_ blogName: String) -> NSAttributedString {
		NSAttributedString(string: blogName, attributes: boldAttributes())
	}

	fileprivate func attributedDescription(_ description: String) -> NSAttributedString {
		let string = "  “\(description)...”  "
		return NSAttributedString(string: string, attributes: normalAttributes())
	}

	fileprivate func attributedDatePosted(_ datePosted: Date, url: URL) -> NSAttributedString {
		let string = formattedDatePosted(datePosted)
		var dateAttributes = boldAttributes()
		dateAttributes[.link] = url.absoluteString as AnyObject?
		return NSAttributedString(string: string, attributes: dateAttributes)
	}

	fileprivate func formattedDatePosted(_ datePosted: Date) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		if dateFromCurrentYear(datePosted) {
			formatter.dateFormat = "MMM d"
		} else {
			formatter.dateFormat = "MMM d yyyy"
		}
		return formatter.string(from: datePosted) + " →"
	}

	fileprivate func dateFromCurrentYear(_ date: Date) -> Bool {
		let dateComponents = (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: date)
		let todayComponents = (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: Date())
		return dateComponents.year == todayComponents.year
	}

	fileprivate func normalAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		let color = NSColor.white.withAlphaComponent(0.5)
		let font = appFont(size: 13)
		attributes[.foregroundColor] = color
		attributes[.font] = font
		return attributes
	}

	fileprivate func boldAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		let color = NSColor.white
		let font = appFont(size: 13, weight: .medium)
		attributes[.foregroundColor] = color
		attributes[.font] = font
		return attributes
	}
}
