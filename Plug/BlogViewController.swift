import Cocoa
import HypeMachineAPI
import Alamofire

final class BlogViewController: BaseContentViewController {
	var blog: HypeMachineAPI.Blog? {
		didSet {
			blogChanged()
		}
	}

	var header: BackgroundBorderView!
	var imageView: BlogImageView!
	var titleButton: HyperlinkButton!
	var detailsTextField: NSTextField!
	var playlistContainer: NSView!

	var tracksViewController: TracksViewController!

	init(blog: HypeMachineAPI.Blog) {
		self.blog = blog
		super.init(title: blog.name, analyticsViewName: "MainWindow/SingleBlog")
		setup()
	}

	init(blogID: Int, blogName: String) {
		super.init(title: blogName, analyticsViewName: "MainWindow/SingleBlog")
		setup()
		loadBlog(blogID)
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
			make.height.greaterThanOrEqualTo(86)
			make.top.equalTo(view)
			make.left.equalTo(view)
			make.right.equalTo(view)
		}

		imageView = BlogImageView()
		header.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.width.equalTo(113)
			make.top.equalTo(header)
			make.bottom.equalTo(header).offset(-1)
			make.right.equalTo(header).offset(-3)
		}

		titleButton = HyperlinkButton()
		titleButton.hasHoverUnderline = true
		titleButton.isBordered = false
		titleButton.font = appFont(size: 20)
		titleButton.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 490), for: .horizontal)
		titleButton.lineBreakMode = .byTruncatingMiddle
		titleButton.target = self
		titleButton.action = #selector(titleButtonClicked(_:))
		header.addSubview(titleButton)
		titleButton.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(header).offset(17)
			make.left.equalTo(header).offset(19)
			make.right.lessThanOrEqualTo(imageView.snp.left).offset(-10)
		}

		detailsTextField = NSTextField()
		detailsTextField.isEditable = false
		detailsTextField.isSelectable = false
		detailsTextField.isBordered = false
		detailsTextField.drawsBackground = false
		header.addSubview(detailsTextField)
		detailsTextField.snp.makeConstraints { make in
			make.height.equalTo(24)
			make.top.equalTo(titleButton.snp.bottom).offset(8)
			make.left.equalTo(header).offset(19)
			make.bottom.equalTo(header).offset(-17)
			make.right.lessThanOrEqualTo(imageView.snp.left).offset(-10)
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

		if blog != nil {
			blogChanged()
		}
	}

	func loadBlog(_ blogID: Int) {
		HypeMachineAPI.Requests.Blogs.show(id: blogID) { [weak self] response in
			guard let self else {
				return
			}

			switch response.result {
			case .success(let blog):
				self.blog = blog
			case .failure(let error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
			}
		}
	}

	func blogChanged() {
		updateTitle()
		updateDetails()
		updateImage()
		loadPlaylist()
		updateActionButton()
	}

	func updateTitle() {
		guard let blog else {
			return
		}

		titleButton.title = blog.name + " →"
	}

	func updateDetails() {
		// TODO: Formatting and stuff
	}

	func updateImage() {
		guard let blog else {
			return
		}

		Alamofire
			.request(blog.imageURL(size: .normal))
			.validate()
			.responseImage { [weak self] response in
				guard let self else {
					return
				}

				switch response.result {
				case .success(let image):
					extractColorAndResizeImage(image)
				case .failure(let error):
					Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
					print(error)
				}
			}
	}

	func extractColorAndResizeImage(_ image: NSImage) {
		guard let blog else {
			return
		}

		DispatchQueue.global().async { [self] in
			let imageSize = CGSize(width: 224, height: 224)
			let colorArt = SLColorArt(image: image, scaledSize: imageSize)!
			let attributedBlogDetails = SingleBlogViewFormatter().attributedBlogDetails(blog, colorArt: colorArt)

			DispatchQueue.main.async { [self] in
				let image = colorArt.scaledImage!
				image.size = CGSize(width: 112, height: 112)
				imageView.image = image
				header.backgroundColor = colorArt.backgroundColor
				detailsTextField.attributedStringValue = attributedBlogDetails
				removeLoaderView()
			}
		}
	}

	@objc
	func titleButtonClicked(_ sender: AnyObject) {
		guard let blog else {
			return
		}

		blog.url.open()
	}

	func loadPlaylist() {
		guard let blog else {
			return
		}

		tracksViewController = TracksViewController(type: .loveCount, title: "", analyticsViewName: "Blog/Tracks")
		addChild(tracksViewController)

		playlistContainer.addSubview(tracksViewController.view)
		tracksViewController.view.snp.makeConstraints { make in
			make.edges.equalTo(playlistContainer)
		}

		tracksViewController.dataSource = BlogTracksDataSource(viewController: tracksViewController, blogID: blog.id)
	}

	func updateActionButton() {
		navigationItem.rightButton?.state = blog?.following == true ? .on : .off
	}

	@objc
	func followButtonClicked(_ sender: ActionButton) {
		guard let blog else {
			return
		}

		HypeMachineAPI.Requests.Me.toggleBlogFavorite(id: blog.id) { response in
			let favoritedState = sender.state == .on

			switch response.result {
			case .success(let favorited):
				guard favorited != favoritedState else {
					return
				}

				sender.state = favorited ? .on : .off
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
