import Cocoa

final class DraggableView: NSView {
	override var mouseDownCanMoveWindow: Bool { true }
}
