import Cocoa

final class LoaderViewController: NSViewController {
	enum LoaderViewSize {
		case small
		case large
	}

	let size: LoaderViewSize
	private lazy var progressIndicator = NSProgressIndicator()

	init?(size: LoaderViewSize) {
		self.size = size
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func startAnimation() {
		progressIndicator.startAnimation(self)
	}

	func stopAnimation() {
		progressIndicator.stopAnimation(self)
	}

	// MARK: NSViewController

	override func loadView() {
		view = NSView(frame: .zero)

		let progressIndicator = NSProgressIndicator()
		progressIndicator.style = .spinning
		progressIndicator.isIndeterminate = true
		if #available(macOS 11, *) {
			progressIndicator.controlSize = size == .large ? .large : .small
		}
		progressIndicator.startAnimation(self)

		view.addSubview(progressIndicator)
		progressIndicator.snp.makeConstraints { make in
			make.center.equalTo(view)
		}
	}

	override func viewDidAppear() {
		startAnimation()
	}
}
