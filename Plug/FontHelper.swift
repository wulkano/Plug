import Foundation

func appFont(size: CGFloat) -> NSFont {
	.systemFont(ofSize: size)
}

func appFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
	.systemFont(ofSize: size, weight: weight)
}
