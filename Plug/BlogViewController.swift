//
//  BlogViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Alamofire

class BlogViewController: BaseContentViewController {
    var blog: HypeMachineAPI.Blog! {
        didSet { blogChanged() }
    }
    
    var header: BackgroundBorderView!
    var imageView: BlogImageView!
    var titleButton: HyperlinkButton!
    var detailsTextField: NSTextField!
    var playlistContainer: NSView!
    
    var tracksViewController: TracksViewController!
    
    init?(blog: HypeMachineAPI.Blog) {
        self.blog = blog
        super.init(title: self.blog.name, analyticsViewName: "MainWindow/SingleBlog")
        setup()
    }
    
    init?(blogID: Int, blogName: String) {
        super.init(title: blogName, analyticsViewName: "MainWindow/SingleBlog")
        setup()
        loadBlog(blogID)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        navigationItem.rightButton = NavigationItem.standardRightButtonWithOnStateTitle("Unfollow", offStateTitle: "Follow", target: self, action: #selector(BlogViewController.followButtonClicked(_:)))
    }
    
    override func loadView() {
        super.loadView()
    
        header = BackgroundBorderView(frame: NSZeroRect)
        header.bottomBorder = true
        header.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
        header.background = true
        header.backgroundColor = NSColor.white
        view.addSubview(header)
        header.snp_makeConstraints { make in
            make.height.greaterThanOrEqualTo(86)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        imageView = BlogImageView()
        header.addSubview(imageView)
        imageView.snp_makeConstraints { make in
            make.width.equalTo(113)
            make.top.equalTo(self.header)
            make.bottom.equalTo(self.header).offset(-1)
            make.right.equalTo(self.header).offset(-3)
        }
        
        titleButton = HyperlinkButton()
        titleButton.hoverUnderline = true
        titleButton.isBordered = false
        titleButton.font = appFont(size: 20)
        titleButton.setContentCompressionResistancePriority(490, for: .horizontal)
        titleButton.lineBreakMode = .byTruncatingMiddle
        titleButton.target = self
        titleButton.action = #selector(BlogViewController.titleButtonClicked(_:))
        header.addSubview(titleButton)
        titleButton.snp_makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalTo(self.header).offset(17)
            make.left.equalTo(self.header).offset(19)
            make.right.lessThanOrEqualTo(self.imageView.snp_left).offset(-10)
        }
        
        detailsTextField = NSTextField()
        detailsTextField.isEditable = false
        detailsTextField.isSelectable = false
        detailsTextField.isBordered = false
        detailsTextField.drawsBackground = false
        header.addSubview(detailsTextField)
        detailsTextField.snp_makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalTo(self.titleButton.snp_bottom).offset(8)
            make.left.equalTo(self.header).offset(19)
            make.bottom.equalTo(self.header).offset(-17)
            make.right.lessThanOrEqualTo(self.imageView.snp_left).offset(-10)
        }
        
        playlistContainer = NSView()
        view.addSubview(playlistContainer)
        playlistContainer.snp_makeConstraints { make in
            make.top.equalTo(self.header.snp_bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if blog != nil { blogChanged() }
    }
    
    func loadBlog(_ blogID: Int) {
        HypeMachineAPI.Requests.Blogs.show(id: blogID) { response in
            switch response.result {
            case .success(let blog):
                self.blog = blog
            case .failure(let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
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
        titleButton.title = blog.name + " →"
    }
    
    func updateDetails() {
        // TODO: formatting n stuff
    }
    
    func updateImage() {
        Alamofire.request(.GET, blog.imageURLForSize(.Normal)).validate().responseImage() { (_, _, result) in
            switch result {
            case .Success(let image):
                self.extractColorAndResizeImage(image)
            case .Failure(_, let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
                print(error as NSError)
            }
        }
    }
    
    func extractColorAndResizeImage(_ image: NSImage) {
        Async.DefaultPriority({
            let imageSize = NSMakeSize(224, 224)
            let colorArt = SLColorArt(image: image, scaledSize: imageSize)
            let attributedBlogDetails = SingleBlogViewFormatter().attributedBlogDetails(self.blog, colorArt: colorArt)
            
            Async.MainQueue({
                let image = colorArt.scaledImage
                image.size = NSMakeSize(112, 112)
                self.imageView.image = image
                self.header.backgroundColor = colorArt.backgroundColor
                self.titleButton.textColor = colorArt.primaryColor
                self.detailsTextField.attributedStringValue = attributedBlogDetails
                self.removeLoaderView()
            })
        })
    }
    
    func titleButtonClicked(_ sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(blog.url)
    }
    
    func loadPlaylist() {
        tracksViewController = TracksViewController(type: .loveCount, title: "", analyticsViewName: "Blog/Tracks")!
        addChildViewController(tracksViewController)
        
        playlistContainer.addSubview(tracksViewController.view)
        tracksViewController.view.snp_makeConstraints { make in
            make.edges.equalTo(playlistContainer)
        }

        tracksViewController.dataSource = BlogTracksDataSource(viewController: tracksViewController, blogID: blog.id)
    }
    
    func updateActionButton() {
        if blog.following {
            navigationItem.rightButton!.state = NSOnState
        } else {
            navigationItem.rightButton!.state = NSOffState
        }
    }
    
    func followButtonClicked(_ sender: ActionButton) {
        HypeMachineAPI.Requests.Me.toggleBlogFavorite(id: blog.id) { response in
            let favoritedState = sender.state == NSOnState
            
            switch response.result {
            case .success(let favorited):
                guard favorited != favoritedState else { return }
                sender.state = favorited ? NSOnState : NSOffState
            case .failure(let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
                print(error)
                
                sender.state = sender.state == NSOffState ? NSOnState : NSOffState
            }
        }
    }
    
    // MARK: BaseContentViewController
    
    override func addLoaderView() {
        loaderViewController = LoaderViewController(size: .small)
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        header.addSubview(loaderViewController!.view)
        loaderViewController!.view.snp_makeConstraints { make in
            make.edges.equalTo(header).inset(insets)
        }
    }
    
    override func refresh() {
        tracksViewController.refresh()
    }
    
    override var shouldShowStickyTrack: Bool {
        return false
    }
}
