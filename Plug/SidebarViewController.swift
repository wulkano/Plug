import Cocoa

final class SidebarViewController: NSViewController {
	let delegate: SidebarViewControllerDelegate
	var buttons = [NavigationSectionButton]()

	init(delegate: SidebarViewControllerDelegate) {
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func loadButtons(superview: NSView) {
		var number = 0
		while let navigationSection = NavigationSection(rawValue: number) {
			let button = NavigationSectionButton(navigationSection: navigationSection)
			button.target = self
			button.action = #selector(navigationSectionButtonClicked(_:))
			superview.addSubview(button)

			button.snp.makeConstraints { make in
				make.centerX.equalTo(superview)
				make.width.equalTo(30)
				make.height.equalTo(30)

				if number == 0 {
					make.top.equalTo(superview).offset(53)
				} else {
					let previousButton = buttons[number - 1]
					make.top.equalTo(previousButton.snp.bottom).offset(28)
				}
			}

			buttons.append(button)
			number += 1
		}

		buttons[buttons.count - 1].snp.makeConstraints { make in
			make.bottom.lessThanOrEqualTo(superview).offset(-30)
		}

		buttons[0].state = .on
	}

	@objc
	func navigationSectionButtonClicked(_ sender: NavigationSectionButton) {
		delegate.changeNavigationSection(sender.navigationSection)
		toggleAllButtonsOffExcept(sender)
	}

	func toggleAllButtonsOffExcept(_ sender: AnyObject) {
		for button in buttons {
			button.state = button === sender ? .on : .off
		}
	}

	// MARK: NSViewController

	private var appearanceObservationToken: NSObjectProtocol?

	override func loadView() {
		view = NSView(frame: .zero)

		let backgroundView = DraggableVisualEffectsView()
		let borderBox = BackgroundBorderView()

		func setMaterial() {
			backgroundView.material = .sidebar

			if !NSApp.effectiveAppearance.isDarkMode {
				backgroundView.appearance = NSAppearance(named: .vibrantDark)
			}

			borderBox.borderColor = NSApp.effectiveAppearance.isDarkMode ? .black : NSColor.black.withAlphaComponent(0.3)
		}

		setMaterial()

		view.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}

		loadButtons(superview: backgroundView)

		appearanceObservationToken = view.observe(\.effectiveAppearance) { _, _ in
			setMaterial()
		}

		borderBox.borderWidth = 1
		borderBox.rightBorder = true
		backgroundView.addSubview(borderBox)
		borderBox.snp.makeConstraints { make in
			make.edges.equalTo(backgroundView)
		}
	}
}

protocol SidebarViewControllerDelegate {
	func changeNavigationSection(_ section: NavigationSection)
}
