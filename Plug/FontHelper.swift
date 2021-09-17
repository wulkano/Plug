import Foundation

func appFont(size: Double) -> NSFont {
	.systemFont(ofSize: size)
}

func appFont(size: Double, weight: NSFont.Weight) -> NSFont {
	.systemFont(ofSize: size, weight: weight)
}
