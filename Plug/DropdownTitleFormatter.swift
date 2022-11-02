import Cocoa

final class DropdownTitleFormatter: Formatter {
	// swiftlint:disable:next discouraged_optional_collection
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

	private func getFont() -> NSFont { .systemFont(ofSize: 0) }
}
