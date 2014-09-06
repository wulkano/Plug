//
//  SingleBlogViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SingleBlogViewController: NSViewController {
    @IBOutlet weak var backgroundView: BackgroundBorderView!
    @IBOutlet weak var titleButton: HyperlinkButton!
    @IBOutlet weak var detailsTextField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var playlistContainer: NSView!
    
    var playlistViewController: BasePlaylistViewController!
    var loaderViewController: LoaderViewController?
    
    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedBlog: Blog {
        return representedObject as Blog
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoadingView()
    }
    
    func representedObjectChanged() {
        updateTitle()
        updateDetails()
        updateImage()
        loadPlaylist()
    }
    
    func updateTitle() {
        titleButton.title = representedBlog.name + " →"
    }
    
    func updateDetails() {
        // TODO: formatting n stuff
    }
    
    func updateImage() {
        HypeMachineAPI.Blogs.Image(representedBlog,
            size: .Normal,
            success: {image in
                self.extractColorAndResizeImage(image)
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    func extractColorAndResizeImage(image: NSImage) {
        Async.DefaultPriority({
            let imageSize = NSMakeSize(224, 224)
            let colorArt = SLColorArt(image: image, scaledSize: imageSize)
            let attributedBlogDetails = SingleBlogViewFormatter().attributedBlogDetails(self.representedBlog, colorArt: colorArt)
            
            Async.MainQueue({
                var image = colorArt.scaledImage
                image.size = NSMakeSize(112, 112)
                self.imageView.image = image
                self.backgroundView.backgroundColor = colorArt.backgroundColor
                self.titleButton.textColor = colorArt.primaryColor
                self.detailsTextField.attributedStringValue = attributedBlogDetails
                self.removeLoadingView()
            })
        })
    }
    
    @IBAction func titleButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(representedBlog.url)
    }
    
    func loadPlaylist() {
        playlistViewController = storyboard.instantiateControllerWithIdentifier("BasePlaylistViewController") as BasePlaylistViewController
        
        addChildViewController(playlistViewController)
        
        ViewPlacementHelper.AddFullSizeSubview(playlistViewController.view, toSuperView: playlistContainer)

        playlistViewController.dataSource = BlogPlaylistDataSource(blog: representedBlog, tableView: playlistViewController.tableView)
    }
    
    func addLoadingView() {
        loaderViewController = storyboard.instantiateControllerWithIdentifier("SmallLoaderViewController") as? LoaderViewController
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        ViewPlacementHelper.AddSubview(loaderViewController!.view, toSuperView: backgroundView, withInsets: insets)
    }
    
    func removeLoadingView() {
        loaderViewController!.view.removeFromSuperview()
        loaderViewController = nil
    }
}
