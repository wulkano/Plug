//
//  MPRemoteCommand+Extensions.swift
//  Plug
//
//  Created by Alex Marchant on 1/2/17.
//  Copyright © 2017 Plug. All rights reserved.
//

import Foundation
import MediaPlayer

@available(OSX 10.12.2, *)
extension MPRemoteCommand {
    
    // Convenience function to simplify the activation
    // of the TouchBar button (aka MPRemoteCommand object)
    func activate(_ target: Any, action: Selector) {
        self.isEnabled = true
        
        self.addTarget(target, action: action)
    }
    
}
