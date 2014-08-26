//
//  Error.swift
//  Plug
//
//  Created by Alex Marchant on 7/24/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlugError: NSObject {
    var primaryMessage: String
    var secondaryMessage: String
    
    init(primaryMessage: String, secondaryMessage: String) {
        self.primaryMessage = primaryMessage
        self.secondaryMessage = secondaryMessage
        super.init()
    }

    class Generator {
        class func UnexpectedApiResponseError() -> PlugError {
            let primaryMessage = "Network Error"
            let secondaryMessage = "Unexpected API response."
            return PlugError(primaryMessage: primaryMessage, secondaryMessage: secondaryMessage)
        }
    }
}