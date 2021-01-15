import Cocoa

final class DropdownTitleFormatter: Formatter {
	override func attributedString(for object: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]?) -> NSAttributedString? {
		attributedDropdownTitle("Popular", optionTitle: "Now")
	}

	override func string(for object: Any?) -> String? {
		attributedDropdownTitle("Popular", optionTitle: "Now").string
	}

	func attributedDropdownTitle(_ title: String?, optionTitle: String?) -> NSAttributedString {
		let formattedViewTitle = formatViewTitle(title ?? "")
		let formattedOptionTitle = formatOptionTitle(optionTitle ?? "")

		let dropdownTitle = NSMutableAttributedString()
		dropdownTitle.append(formattedViewTitle)
		dropdownTitle.append(formattedOptionTitle)

		return dropdownTitle
	}

	private func formatViewTitle(_ viewTitle: String) -> NSAttributedString {
		NSAttributedString(string: viewTitle, attributes: viewTitleAttributes())
	}

	private func formatOptionTitle(_ optionTitle: String) -> NSAttributedString {
		NSAttributedString(string: " (\(optionTitle))", attributes: optionTitleAttributes())
	}

	private func viewTitleAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.labelColor
		attributes[.font] = getFont()
		return attributes
	}

	private func optionTitleAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.secondaryLabelColor
		attributes[.font] = getFont()
		return attributes
	}

	private func getFont() -> NSFont {
		if #available(macOS 11, *) {
			return .systemFont(ofSize: 0)
		} else {
			return appFont(size: 14, weight: .medium)
		}
	}
}
