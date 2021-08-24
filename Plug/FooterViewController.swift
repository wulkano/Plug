import Cocoa
import AVKit
import Combine

final class FooterViewController: NSViewController {
	var volumeIcon: VolumeIconView!
	var volumeSlider: NSSlider!
	var shuffleButton: SwissArmyButton!

	private var cancellables = Set<AnyCancellable>()
	private let routeDetector = AVRouteDetector()

	func toggleShuffle() {
		AudioPlayer.shared.toggleShuffle()
	}

	// MARK: Actions

	@objc
	func skipForwardButtonClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Footer Skip Forward")
		AudioPlayer.shared.skipForward()
	}

	@objc
	func skipBackwardButtonClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Footer Skip Backward")
		AudioPlayer.shared.skipBackward()
	}

	@objc
	func shuffleButtonClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Footer Shuffle")
		toggleShuffle()
	}

	// MARK: NSViewController

	override func loadView() {
		view = NSView(frame: .zero)

		routeDetector.isRouteDetectionEnabled = true

		let backgroundView = DraggableVisualEffectsView()
		backgroundView.blendingMode = .withinWindow
		view.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}

		let borderBox = BackgroundBorderView()
		borderBox.borderWidth = 1
		borderBox.topBorder = true
		backgroundView.addSubview(borderBox)
		borderBox.snp.makeConstraints { make in
			make.edges.equalTo(backgroundView)
		}

		volumeIcon = VolumeIconView(frame: .zero)
		volumeIcon.offImage = NSImage(named: "Footer-Volume-Off")
		volumeIcon.oneImage = NSImage(named: "Footer-Volume-1")
		volumeIcon.twoImage = NSImage(named: "Footer-Volume-2")
		volumeIcon.threeImage = NSImage(named: "Footer-Volume-3")
		backgroundView.addSubview(volumeIcon)
		volumeIcon.snp.makeConstraints { make in
			make.width.equalTo(16)
			make.height.equalTo(15)
			make.centerY.equalTo(backgroundView).offset(-1)
			make.left.equalTo(backgroundView).offset(20)
		}

		volumeSlider = NSSlider(frame: .zero)
		let cell = FlatSliderCell()
		cell.barColor = .quaternaryLabelColor
		cell.barFillColor = .tertiaryLabelColor
		volumeSlider.cell = cell
		volumeSlider.controlSize = .mini
		backgroundView.addSubview(volumeSlider)
		volumeSlider.snp.makeConstraints { make in
			make.centerY.equalTo(backgroundView)
			make.width.equalTo(60)
			make.left.equalTo(backgroundView).offset(40)
		}

		let airPlayButton = AVRoutePickerView()
		airPlayButton.isHidden = !routeDetector.multipleRoutesDetected
		airPlayButton.isRoutePickerButtonBordered = false
		airPlayButton.setRoutePickerButtonColor(.tertiaryLabelColor, for: .normal)
		airPlayButton.setRoutePickerButtonColor(.secondaryLabelColor, for: .normalHighlighted)
		airPlayButton.player = AudioPlayer.shared.player
		backgroundView.addSubview(airPlayButton)

		airPlayButton.snp.makeConstraints { make in
			make.centerY.equalTo(backgroundView)
			make.left.equalTo(volumeSlider).offset(70)
		}

		NotificationCenter.default.publisher(for: .AVRouteDetectorMultipleRoutesDetectedDidChange)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				guard let self = self else {
					return
				}

				airPlayButton.isHidden = !self.routeDetector.multipleRoutesDetected
			}
			.store(in: &cancellables)

		AudioPlayer.shared.playerDidChangePublisher
			.receive(on: DispatchQueue.main)
			.sink {
				airPlayButton.player = AudioPlayer.shared.player
			}
			.store(in: &cancellables)

		shuffleButton = SwissArmyButton(frame: .zero)
		let shuffleCell = TransparentButtonCell(textCell: "")
		shuffleCell.allowsSelectedState = true
		shuffleButton.cell = shuffleCell
		shuffleButton.isBordered = false
		shuffleButton.isTrackingHover = true
		shuffleButton.image = NSImage(named: "Footer-Shuffle-Normal")
		shuffleButton.alternateImage = NSImage(named: "Footer-Shuffle-Active")
		shuffleButton.target = self
		shuffleButton.action = #selector(FooterViewController.shuffleButtonClicked(_:))
		backgroundView.addSubview(shuffleButton)
		shuffleButton.snp.makeConstraints { make in
			make.width.equalTo(42)
			make.top.equalTo(backgroundView)
			make.bottom.equalTo(backgroundView)
			make.right.equalTo(backgroundView).offset(-8)
		}

		let forwardButton = SwissArmyButton(frame: .zero)
		let forwardCell = TransparentButtonCell(textCell: "")
		forwardButton.cell = forwardCell
		forwardButton.isBordered = false
		forwardButton.isTrackingHover = true
		forwardButton.image = NSImage(named: "Footer-Forward")
		forwardButton.target = self
		forwardButton.action = #selector(FooterViewController.skipForwardButtonClicked(_:))
		backgroundView.addSubview(forwardButton)
		forwardButton.snp.makeConstraints { make in
			make.width.equalTo(42)
			make.top.equalTo(backgroundView)
			make.bottom.equalTo(backgroundView)
			make.right.equalTo(shuffleButton.snp.left)
		}

		let backButton = SwissArmyButton(frame: .zero)
		let backCell = TransparentButtonCell(textCell: "")
		backButton.cell = backCell
		backButton.isBordered = false
		backButton.isTrackingHover = true
		backButton.image = NSImage(named: "Footer-Previous")
		backButton.target = self
		backButton.action = #selector(FooterViewController.skipBackwardButtonClicked(_:))
		backgroundView.addSubview(backButton)
		backButton.snp.makeConstraints { make in
			make.width.equalTo(42)
			make.top.equalTo(backgroundView)
			make.left.greaterThanOrEqualTo(volumeSlider.snp.right).offset(50)
			make.bottom.equalTo(backgroundView)
			make.right.equalTo(forwardButton.snp.left)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		volumeSlider.bind(NSBindingName("value"), to: NSUserDefaultsController.shared, withKeyPath: "values.volume", options: nil)
		volumeIcon.bind(NSBindingName("volume"), to: NSUserDefaultsController.shared, withKeyPath: "values.volume", options: nil)
		shuffleButton.bind(NSBindingName("state"), to: NSUserDefaultsController.shared, withKeyPath: "values.shuffle", options: nil)
	}
}
