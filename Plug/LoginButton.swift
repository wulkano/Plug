//
//  LoginButton.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginButton: SwissArmyButton {
    var loginButtonCell: LoginButtonCell {
        return cell() as LoginButtonCell
    }
    var buttonState: LoginButtonState = .Disabled {
        didSet { buttonStateChanged() }
    }
    var loadingImageView: NSImageView?
    
    func buttonStateChanged() {
        updateTitle()
        updateEnabled()
        updateImage()
        updateLoadingImageView()
    }
    
    func updateTitle() {
        title = buttonState.title()
    }
    
    func updateEnabled() {
        switch buttonState {
        case .Disabled, .Sending:
            enabled = false
        case .Enabled, .Error:
            enabled = true
        }
    }
    
    func updateImage() {
        image = buttonState.image()
    }
    
    func updateLoadingImageView() {
        switch buttonState {
        case .Sending:
            setupLoadingImageView()
        default:
            destroyLoadingImageView()
        }
    }
    
    func setupLoadingImageView() {
        if loadingImageView == nil {
            var loaderImage = buttonState.image()
            var imageFrame = NSMakeRect(244.0,8.0,20.0,20.0)
            loadingImageView = NSImageView(frame: imageFrame)
            loadingImageView!.image = loaderImage
            addSubview(loadingImageView!)
            Animations.RotateCounterClockwise(loadingImageView!)
        }
    }
    
    func destroyLoadingImageView() {
        if loadingImageView != nil {
            loadingImageView!.removeFromSuperview()
            loadingImageView = nil
        }
    }
    
    enum LoginButtonState {
        case Disabled
        case Enabled
        case Sending
        case Error(String)
        
        func title() -> String {
            var titleString: String
            
            switch self {
            case .Disabled, .Enabled:
                titleString = "Log in"
            case .Sending:
                titleString = "Logging in..."
            case .Error(let message):
                titleString = message
            }
            
            return titleString.uppercaseString
        }
        
        func image() -> NSImage? {
            switch self {
            case .Disabled, .Enabled:
                return NSImage(named: "Login-Next")
            case .Sending:
                return NSImage(named: "Loader-Login")
            case .Error(let message):
                return NSImage(named: "Login-Error")
            }
        }
    }
}
