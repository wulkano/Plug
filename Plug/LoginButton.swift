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
        return cell as! LoginButtonCell
    }
    var buttonState: LoginButtonState = .disabled {
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
        case .disabled, .sending:
            isEnabled = false
        case .enabled, .error:
            isEnabled = true
        }
    }
    
    func updateImage() {
        image = buttonState.image()
    }
    
    func updateLoadingImageView() {
        switch buttonState {
        case .sending:
            setupLoadingImageView()
        default:
            destroyLoadingImageView()
        }
    }
    
    func setupLoadingImageView() {
        if loadingImageView == nil {
            let loaderImage = buttonState.image()
            let imageFrame = NSMakeRect(244.0,8.0,20.0,20.0)
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
        case disabled
        case enabled
        case sending
        case error(String)
        
        func title() -> String {
            var titleString: String
            
            switch self {
            case .disabled, .enabled:
                titleString = "Log in"
            case .sending:
                titleString = "Logging in..."
            case .error(let message):
                titleString = message
            }
            
            return titleString
        }
        
        func image() -> NSImage? {
            switch self {
            case .disabled, .enabled:
                return NSImage(named: "Login-Next")
            case .sending:
                return NSImage(named: "Loader-Login")
            case .error:
                return NSImage(named: "Login-Error")
            }
        }
    }
}
