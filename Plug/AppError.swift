//
//  Error.swift
//  Plug
//
//  Created by Alex Marchant on 7/24/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class AppError: NSObject {
    class func postErrorNotification(error: NSError, object: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error, object: object, userInfo: ["error": error])
    }
    
    class func fromNotification(notification: NSNotification) -> NSError {
        return notification.userInfo["error"] as NSError
    }
    
    class func logError(error: NSError) {
        println("AppError: \(error.localizedDescription)")
    }
}
