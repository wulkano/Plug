//
//  FooterViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FooterViewController: NSViewController {
    var volumeIcon: VolumeIconView!
    var volumeSlider: NSSlider!
    var shuffleButton: SwissArmyButton!
    
    func toggleShuffle() {
        let oldShuffle = NSUserDefaults.standardUserDefaults().valueForKey("shuffle") as! Bool
        let newShuffle = !oldShuffle
        NSUserDefaults.standardUserDefaults().setValue(newShuffle, forKey: "shuffle")
    }
    
    // MARK: Actions
    
    func skipForwardButtonClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Footer Skip Forward")
        AudioPlayer.sharedInstance.skipForward()
    }
    
    func skipBackwardButtonClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Footer Skip Backward")
        AudioPlayer.sharedInstance.skipBackward()
    }

    func shuffleButtonClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Footer Shuffle")
        toggleShuffle()
    }
    
    // MARK: NSViewController
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        let backgroundView = DraggableVisualEffectsView()
        backgroundView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        backgroundView.blendingMode = .WithinWindow
        view.addSubview(backgroundView)
        backgroundView.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        let borderBox = BackgroundBorderView()
        borderBox.borderWidth = 1
        borderBox.borderColor = NSColor(red256: 225, green256: 226, blue256: 226)
        borderBox.topBorder = true
        backgroundView.addSubview(borderBox)
        borderBox.snp_makeConstraints { make in
            make.edges.equalTo(backgroundView)
        }
        
        volumeIcon = VolumeIconView(frame: NSZeroRect)
        volumeIcon.offImage = NSImage(named: "Footer-Volume-Off")
        volumeIcon.oneImage = NSImage(named: "Footer-Volume-1")
        volumeIcon.twoImage = NSImage(named: "Footer-Volume-2")
        volumeIcon.threeImage = NSImage(named: "Footer-Volume-3")
        backgroundView.addSubview(volumeIcon)
        volumeIcon.snp_makeConstraints { make in
            make.width.equalTo(16)
            make.height.equalTo(15)
            make.centerY.equalTo(backgroundView).offset(-1)
            make.left.equalTo(backgroundView).offset(20)
        }
        
        volumeSlider = NSSlider(frame: NSZeroRect)
        let cell = FlatSliderCell()
        cell.barColor = NSColor(red256: 225, green256: 226, blue256: 226)
        cell.barFillColor = NSColor(red256: 175, green256: 175, blue256: 176)
        cell.knobSize = 10
        volumeSlider.cell = cell
        volumeSlider.controlSize = .MiniControlSize
        backgroundView.addSubview(volumeSlider)
        volumeSlider.snp_makeConstraints { make in
            make.centerY.equalTo(backgroundView)
            make.width.equalTo(60)
            make.left.equalTo(backgroundView).offset(40)
        }
        
        shuffleButton = SwissArmyButton(frame: NSZeroRect)
        let shuffleCell = TransparentButtonCell(textCell: "")
        shuffleCell.allowsSelectedState = true
        shuffleButton.cell = shuffleCell
        shuffleButton.bordered = false
        shuffleButton.tracksHover = true
        shuffleButton.image = NSImage(named: "Footer-Shuffle-Normal")
        shuffleButton.alternateImage = NSImage(named: "Footer-Shuffle-Active")
        shuffleButton.target = self
        shuffleButton.action = #selector(FooterViewController.shuffleButtonClicked(_:))
        backgroundView.addSubview(shuffleButton)
        shuffleButton.snp_makeConstraints { make in
            make.width.equalTo(42)
            make.top.equalTo(backgroundView)
            make.bottom.equalTo(backgroundView)
            make.right.equalTo(backgroundView).offset(-8)
        }
        
        let forwardButton = SwissArmyButton(frame: NSZeroRect)
        let forwardCell = TransparentButtonCell(textCell: "")
        forwardButton.cell = forwardCell
        forwardButton.bordered = false
        forwardButton.tracksHover = true
        forwardButton.image = NSImage(named: "Footer-Forward")
        forwardButton.target = self
        forwardButton.action = #selector(FooterViewController.skipForwardButtonClicked(_:))
        backgroundView.addSubview(forwardButton)
        forwardButton.snp_makeConstraints { make in
            make.width.equalTo(42)
            make.top.equalTo(backgroundView)
            make.bottom.equalTo(backgroundView)
            make.right.equalTo(shuffleButton.snp_left)
        }
        
        let backButton = SwissArmyButton(frame: NSZeroRect)
        let backCell = TransparentButtonCell(textCell: "")
        backButton.cell = backCell
        backButton.bordered = false
        backButton.tracksHover = true
        backButton.image = NSImage(named: "Footer-Previous")
        backButton.target = self
        backButton.action = #selector(FooterViewController.skipBackwardButtonClicked(_:))
        backgroundView.addSubview(backButton)
        backButton.snp_makeConstraints { make in
            make.width.equalTo(42)
            make.top.equalTo(backgroundView)
            make.left.greaterThanOrEqualTo(volumeSlider.snp_right).offset(50)
            make.bottom.equalTo(backgroundView)
            make.right.equalTo(forwardButton.snp_left)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        volumeSlider.bind("value", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
        volumeIcon.bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
        shuffleButton.bind("state", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.shuffle", options: nil)
    }
}