import Cocoa
import SnapKit

final class DisplayErrorViewController: NSViewController {
	let error: NSError

	var errorTitleTextField: NSTextField!
	var errorDescriptionTextField: NSTextField!

	var bottomConstraint: Constraint?
	var topConstraint: Constraint?

	init!(error: NSError) {
		self.error = error
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = NSView(frame: .zero)

		let background = BackgroundBorderView()
		background.hasBackground = true
		background.backgroundColor = NSColor(red256: 255, green256: 95, blue256: 82)
		view.addSubview(background)
		background.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}

		errorTitleTextField = NSTextField(frame: .zero)
		errorTitleTextField.stringValue = "Error"
		errorTitleTextField.isEditable = false
		errorTitleTextField.isSelectable = false
		errorTitleTextField.isBordered = false
		errorTitleTextField.drawsBackground = false
		errorTitleTextField.lineBreakMode = .byWordWrapping
		errorTitleTextField.font = appFont(size: 14, weight: .medium)
		errorTitleTextField.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 490), for: .horizontal)
		errorTitleTextField.textColor = .white
		view.addSubview(errorTitleTextField)
		errorTitleTextField.snp.makeConstraints { make in
			make.top.equalTo(view).offset(6)
			make.left.equalTo(view).offset(14)
			make.right.equalTo(view).offset(-14)
		}

		errorDescriptionTextField = NSTextField(frame: .zero)
		errorDescriptionTextField.stringValue = error.localizedDescription
		errorDescriptionTextField.isEditable = false
		errorDescriptionTextField.isSelectable = false
		errorDescriptionTextField.isBordered = false
		errorDescriptionTextField.drawsBackground = false
		errorDescriptionTextField.lineBreakMode = .byWordWrapping
		errorDescriptionTextField.font = appFont(size: 13)
		errorDescriptionTextField.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 490), for: .horizontal)
		errorDescriptionTextField.textColor = .white
		view.addSubview(errorDescriptionTextField)
		errorDescriptionTextField.snp.makeConstraints { make in
			make.top.equalTo(errorTitleTextField.snp.bottom)
			make.left.equalTo(view).offset(14)
			make.right.equalTo(view).offset(-14)
			make.bottom.equalTo(view).offset(-14)
		}
	}

	override func viewDidLayout() {
		super.viewDidLayout()
		errorTitleTextField.preferredMaxLayoutWidth = errorTitleTextField.frame.size.width
		errorDescriptionTextField.preferredMaxLayoutWidth = errorDescriptionTextField.frame.size.width
		view.layoutSubtreeIfNeeded()
	}

	func setupLayoutInSuperview() {
		view.snp.makeConstraints { make in
			bottomConstraint = make.bottom.equalTo(view.superview!.snp.top).constraint
			make.left.equalTo(view.superview!)
			make.right.equalTo(view.superview!)
		}
	}

	func animateIn() {
		view.superview!.layoutSubtreeIfNeeded()

		bottomConstraint!.deactivate()

		view.snp.makeConstraints { make in
			topConstraint = make.top.equalTo(view.superview!).constraint
		}

		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.25
			context.allowsImplicitAnimation = true
			context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			self.view.superview!.layoutSubtreeIfNeeded()
		}, completionHandler: nil)
	}

	func animateOutWithDelay(_ delay: Double, completionHandler: @escaping () -> Void) {
		Interval.single(delay) {
			self.view.superview!.layoutSubtreeIfNeeded()

			self.topConstraint!.deactivate()

			self.view.snp.makeConstraints { make in
				make.bottom.equalTo(self.view.superview!.snp.top)
			}

			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.25
				context.allowsImplicitAnimation = true
				context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
				self.view.superview!.layoutSubtreeIfNeeded()
			}, completionHandler: {
				completionHandler()
			})
		}
	}
}
