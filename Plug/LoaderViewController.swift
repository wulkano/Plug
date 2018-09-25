//
//  LoaderViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoaderViewController: NSViewController {
    let size: LoaderViewSize
    var loaderView: NSImageView!
    
    init?(size: LoaderViewSize) {
        self.size = size
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        Animations.RotateClockwise(loaderView)
    }
    
    func stopAnimation() {
        Animations.RemoveAllAnimations(loaderView)
    }
    
    // MARK: NSViewController
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        let background = BackgroundBorderView()
        background.background = true
        background.backgroundColor = NSColor.controlBackgroundColor
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        loaderView = NSImageView()
        switch size {
        case .small:
            loaderView.image = NSImage(named: "Loader-Small")
        case .large:
            loaderView.image = NSImage(named: "Loader-Large")
        }
        view.addSubview(loaderView)
        loaderView.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    override func viewDidAppear() {
        startAnimation()
    }
}

enum LoaderViewSize {
    case small
    case large
}
