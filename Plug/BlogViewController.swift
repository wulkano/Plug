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
    
    override var analyticsViewName: String {
        return "MainWindow/SingleBlog"
    }
    
    var tracksViewController: TracksViewController!
    
    init!(blog: HypeMachineAPI.Blog) {
        self.blog = blog
        
        super.init(nibName: nil, bundle: nil)
        
        title = self.blog.name
    }
    
    init!(blogID: Int, blogName: String) {
        super.init(nibName: nil, bundle: nil)
        
        title = blogName
        loadBlog(blogID)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
    
        header = BackgroundBorderView(frame: NSZeroRect)
        header.bottomBorder = true
        header.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
        header.background = true
        header.backgroundColor = NSColor.whiteColor()
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
        titleButton.bordered = false
        titleButton.font = NSFont(name: "HelveticaNeue", size: 20)!
        header.addSubview(titleButton)
        titleButton.snp_makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalTo(self.header).offset(17)
            make.left.equalTo(self.header).offset(19)
            make.right.lessThanOrEqualTo(self.imageView.snp_left).offset(-10)
        }
        
        detailsTextField = NSTextField()
        detailsTextField.editable = false
        detailsTextField.selectable = false
        detailsTextField.bordered = false
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
        
        displayActionButton = true
        actionButtonTarget = self
        actionButtonAction = "followButtonClicked:"
        
        if blog != nil { blogChanged() }
    }
    
    func loadBlog(blogID: Int) {
        HypeMachineAPI.Requests.Blogs.show(id: blogID) {
            (blog, error) in
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error)
                return
            }
            
            self.blog = blog
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
        Alamofire.request(.GET, blog.imageURLForSize(.Normal)).validate().responseImage() {
            (_, _, image, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                return
            }
            
            self.extractColorAndResizeImage(image!)
        }
    }
    
    func extractColorAndResizeImage(image: NSImage) {
        Async.DefaultPriority({
            let imageSize = NSMakeSize(224, 224)
            let colorArt = SLColorArt(image: image, scaledSize: imageSize)
            let attributedBlogDetails = SingleBlogViewFormatter().attributedBlogDetails(self.blog, colorArt: colorArt)
            
            Async.MainQueue({
                var image = colorArt.scaledImage
                image.size = NSMakeSize(112, 112)
                self.imageView.image = image
                self.header.backgroundColor = colorArt.backgroundColor
                self.titleButton.textColor = colorArt.primaryColor
                self.detailsTextField.attributedStringValue = attributedBlogDetails
                self.removeLoaderView()
            })
        })
    }
    
    @IBAction func titleButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(blog.url)
    }
    
    func loadPlaylist() {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))!
        tracksViewController = mainStoryboard.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController
        
        addChildViewController(tracksViewController)
        
        playlistContainer.addSubview(tracksViewController.view)
        tracksViewController.view.snp_makeConstraints { make in
            make.edges.equalTo(playlistContainer)
        }

        tracksViewController.dataSource = BlogTracksDataSource(viewController: tracksViewController, blogID: blog.id)
    }
    
    override func addLoaderView() {
        loaderViewController = LoaderViewController(size: .Small)
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        header.addSubview(loaderViewController!.view)
        loaderViewController!.view.snp_makeConstraints { make in
            make.edges.equalTo(header).insets(insets)
        }
    }
    
    override func refresh() {
        tracksViewController.refresh()
    }
    
    func updateActionButton() {
//        if blog.following {
//            actionButton!.state = NSOnState
//        } else {
//            actionButton!.state = NSOffState
//        }
    }
    
    func followButtonClicked(sender: ActionButton) {
        HypeMachineAPI.Requests.Me.toggleBlogFavorite(id: blog.id, optionalParams: nil) { (favorited, error) in
            let favoritedState = sender.state == NSOnState
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                
                if sender.state == NSOffState {
                    sender.state = NSOnState
                } else {
                    sender.state = NSOffState
                }
                
                return
            }
            
            if favorited! != favoritedState {
                if favorited! {
                    sender.state = NSOnState
                } else {
                    sender.state = NSOffState
                }
            }
        }
    }
}
