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
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        loaderView = NSImageView()
        switch size {
        case .Small:
            loaderView.image = NSImage(named: "Loader-Small")
        case .Large:
            loaderView.image = NSImage(named: "Loader-Large")
        }
        view.addSubview(loaderView)
        loaderView.snp_makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    override func viewDidAppear() {
        startAnimation()
    }
    
    func startAnimation() {
        Animations.RotateClockwise(loaderView)
    }
    
    func stopAnimation() {
        Animations.RemoveAllAnimations(loaderView)
    }
}

enum LoaderViewSize {
    case Small
    case Large
}