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
    
    var tracksViewController: TracksViewController!
    
    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedBlog: HypeMachineAPI.Blog {
        return representedObject as! HypeMachineAPI.Blog
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayActionButton = true
        actionButtonTarget = self
        actionButtonAction = "followButtonClicked:"
    }
    
    func representedObjectChanged() {
        updateTitle()
        updateDetails()
        updateImage()
        loadPlaylist()
        updateActionButton()
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
        tracksViewController = storyboard!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController
        
        addChildViewController(tracksViewController)
        
        playlistContainer.addSubview(tracksViewController.view)
        tracksViewController.view.snp_makeConstraints { make in
            make.edges.equalTo(playlistContainer)
        }

        tracksViewController.dataSource = BlogTracksDataSource(viewController: tracksViewController, blogID: representedBlog.id)
    }
    
    override func addLoaderView() {
        loaderViewController = LoaderViewController(size: .Small)
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        backgroundView.addSubview(loaderViewController!.view)
        loaderViewController!.view.snp_makeConstraints { make in
            make.edges.equalTo(backgroundView).insets(insets)
        }
    }
    
    override func refresh() {
        tracksViewController.refresh()
    }
    
    func updateActionButton() {
        if representedBlog.following {
            actionButton!.state = NSOnState
        } else {
            actionButton!.state = NSOffState
        }
    }
    
    func followButtonClicked(sender: ActionButton) {
        HypeMachineAPI.Requests.Me.toggleBlogFavorite(id: representedBlog.id, optionalParams: nil) { (favorited, error) in
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
