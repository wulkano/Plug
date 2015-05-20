//
//  SingleBlogViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Alamofire

class SingleBlogViewController: BaseContentViewController {
    @IBOutlet weak var backgroundView: BackgroundBorderView!
    @IBOutlet weak var titleButton: HyperlinkButton!
    @IBOutlet weak var detailsTextField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var playlistContainer: NSView!
    override var analyticsViewName: String {
        return "MainWindow/SingleBlog"
    }
    
    var playlistViewController: BasePlaylistViewController!
    
    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedBlog: HypeMachineAPI.Blog {
        return representedObject as! HypeMachineAPI.Blog
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
        Alamofire.request(.GET, representedBlog.imageURLForSize(.Normal)).validate().responseImage() {
            (_, _, image, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                Logger.LogError(error!)
                return
            }
            
            self.extractColorAndResizeImage(image!)
        }
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
                self.removeLoaderView()
            })
        })
    }
    
    @IBAction func titleButtonClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(representedBlog.url)
    }
    
    func loadPlaylist() {
        playlistViewController = storyboard!.instantiateControllerWithIdentifier("BasePlaylistViewController") as! BasePlaylistViewController
        
        addChildViewController(playlistViewController)
        
        ViewPlacementHelper.AddFullSizeSubview(playlistViewController.view, toSuperView: playlistContainer)

        playlistViewController.dataSource = BlogPlaylistDataSource(blog: representedBlog, viewController: playlistViewController)
    }
    
    override func addLoaderView() {
        loaderViewController = storyboard!.instantiateControllerWithIdentifier("SmallLoaderViewController") as? LoaderViewController
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        ViewPlacementHelper.AddSubview(loaderViewController!.view, toSuperView: backgroundView, withInsets: insets)
    }
    
    override func refresh() {
        playlistViewController.refresh()
    }
}
