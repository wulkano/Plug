import Cocoa
import HypeMachineAPI
import Alamofire

final class UserViewController: BaseContentViewController {
	var user: HypeMachineAPI.User? {
		didSet {
			userChanged()
		}
	}

	var header: BackgroundBorderView!
	var avatarView: NSImageView!
	var usernameTextField: NSTextField!
	var favoritesCountTextField: NSTextField!
	var friendsCountTextField: NSTextField!
	var playlistContainer: NSView!

	var tracksViewController: TracksViewController!

	init(user: HypeMachineAPI.User) {
		self.user = user
		super.init(title: user.username, analyticsViewName: "MainWindow/SingleUser")
		setup()
	}

	init(username: String) {
		super.init(title: username, analyticsViewName: "MainWindow/SingleUser")
		loadUser(username)
		setup()
	}

	func setup() {
		navigationItem.rightButton = NavigationItem.standardRightButtonWithOnStateTitle("Unfollow", offStateTitle: "Follow", target: self, action: #selector(followButtonClicked(_:)))
	}

	override func loadView() {
		super.loadView()

		header = BackgroundBorderView(frame: .zero)
		header.bottomBorder = true
		view.addSubview(header)
		header.snp.makeConstraints { make in
			make.height.equalTo(86)
			make.top.equalTo(view)
			make.left.equalTo(view)
			make.right.equalTo(view)
		}

		avatarView = CircleMaskImageView()
		avatarView.image = NSImage(named: "Avatar-Placeholder")!
		header.addSubview(avatarView)
		avatarView.snp.makeConstraints { make in
			make.centerY.equalTo(header)
			make.width.equalTo(36)
			make.height.equalTo(36)
			make.left.equalTo(header).offset(17)
		}

		usernameTextField = NSTextField()
		usernameTextField.isEditable = false
		usernameTextField.isSelectable = false
		usernameTextField.isBordered = false
		usernameTextField.drawsBackground = false
		usernameTextField.font = appFont(size: 20)
		header.addSubview(usernameTextField)
		usernameTextField.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(header).offset(17)
			make.left.equalTo(avatarView.snp.right).offset(22)
			make.right.equalTo(header).offset(-20)
		}

		favoritesCountTextField = NSTextField()
		favoritesCountTextField.isEditable = false
		favoritesCountTextField.isSelectable = false
		favoritesCountTextField.isBordered = false
		favoritesCountTextField.drawsBackground = false
		favoritesCountTextField.font = appFont(size: 13, weight: .medium)
		header.addSubview(favoritesCountTextField)
		favoritesCountTextField.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(usernameTextField.snp.bottom).offset(8)
			make.left.equalTo(avatarView.snp.right).offset(22)
		}

		let favoritesLabel = NSTextField()
		favoritesLabel.isEditable = false
		favoritesLabel.isSelectable = false
		favoritesLabel.isBordered = false
		favoritesLabel.drawsBackground = false
		favoritesLabel.font = appFont(size: 13, weight: .medium)
		favoritesLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
		favoritesLabel.stringValue = "Favorites"
		header.addSubview(favoritesLabel)
		favoritesLabel.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(usernameTextField.snp.bottom).offset(8)
			make.left.equalTo(favoritesCountTextField.snp.right).offset(3)
		}

		friendsCountTextField = NSTextField()
		friendsCountTextField.isEditable = false
		friendsCountTextField.isSelectable = false
		friendsCountTextField.isBordered = false
		friendsCountTextField.drawsBackground = false
		friendsCountTextField.font = appFont(size: 13, weight: .medium)
		header.addSubview(friendsCountTextField)
		friendsCountTextField.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(usernameTextField.snp.bottom).offset(8)
			make.left.equalTo(favoritesLabel.snp.right).offset(13)
		}

		let friendsLabel = NSTextField()
		friendsLabel.isEditable = false
		friendsLabel.isSelectable = false
		friendsLabel.isBordered = false
		friendsLabel.drawsBackground = false
		friendsLabel.font = appFont(size: 13, weight: .medium)
		friendsLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
		friendsLabel.stringValue = "Friends"
		header.addSubview(friendsLabel)
		friendsLabel.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(usernameTextField.snp.bottom).offset(8)
			make.left.equalTo(friendsCountTextField.snp.right).offset(3)
		}

		playlistContainer = NSView()
		view.addSubview(playlistContainer)
		playlistContainer.snp.makeConstraints { make in
			make.top.equalTo(header.snp.bottom)
			make.left.equalTo(view)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if user != nil {
			userChanged()
		}
	}

	func loadUser(_ username: String) {
		HypeMachineAPI.Requests.Users.show(username: username) { [weak self] response in
			guard let self else {
				return
			}

			switch response.result {
			case .success(let user):
				self.user = user
			case .failure(let error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
			}
		}
	}

	func userChanged() {
		updateImage()
		updateUsername()
		updateFavoritesCount()
		updateFriendsCount()
		loadPlaylist()
		removeLoaderView()
		updateActionButton()
	}

	func updateImage() {
		guard let avatarURL = user?.avatarURL else {
			return
		}

		Alamofire.request(avatarURL, method: .get)
			.validate()
			.responseImage { [weak self] response in
				guard let self else {
					return
				}

				switch response.result {
				case .success(let image):
					self.avatarView.image = image
				case .failure(let error):
					Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
					print(error)
				}
			}
	}

	func updateUsername() {
		usernameTextField.stringValue = user!.username
	}

	func updateFavoritesCount() {
		favoritesCountTextField.integerValue = user!.favoritesCount
	}

	func updateFriendsCount() {
		friendsCountTextField.integerValue = user!.followersCount
	}

	func loadPlaylist() {
		tracksViewController = TracksViewController(type: .loveCount, title: "", analyticsViewName: "User/Tracks")
		addChild(tracksViewController)
		playlistContainer.addSubview(tracksViewController.view)
		tracksViewController.view.snp.makeConstraints { make in
			make.edges.equalTo(playlistContainer)
		}
		tracksViewController.dataSource = UserTracksDataSource(viewController: tracksViewController, username: user!.username)
	}

	func updateActionButton() {
		if user!.friend! == true {
			navigationItem!.rightButton!.state = .on
		} else {
			navigationItem!.rightButton!.state = .off
		}
	}

	@objc
	func followButtonClicked(_ sender: ActionButton) {
		HypeMachineAPI.Requests.Me.toggleUserFavorite(id: user!.username) { response in
			let favoritedState = sender.state == .on

			switch response.result {
			case .success(let favorited):
				if favorited != favoritedState {
					sender.state = favorited ? .on : .off
				}
			case .failure(let error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)

				sender.state = sender.state == .off ? .on : .off
			}
		}
	}

	// MARK: BaseContentViewController

	override func addLoaderView() {
		loaderViewController = LoaderViewController(size: .small)
		let insets = NSEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
		header.addSubview(loaderViewController!.view)
		loaderViewController!.view.snp.makeConstraints { make in
			make.edges.equalTo(header).inset(insets)
		}
	}

	override func refresh() {
		tracksViewController.refresh()
	}

	override var shouldShowStickyTrack: Bool { false }
}
