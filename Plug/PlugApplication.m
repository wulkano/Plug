//
//  PlugApplication.m
//  Plug
//
//  Created by Alex Marchant on 9/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

#import "PlugApplication.h"
#import "SPMediaKeyTap.h"

@implementation PlugApplication

//- (void)sendEvent:(NSEvent *)theEvent {
//    // If event tap is not installed, handle events that reach the app instead
//    BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
//    
//    if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlugReceivedMediaKeyEvent" object:self];
////        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPaused, object: sender, userInfo: ["track": track])
////        [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
//    }
//    [super sendEvent:theEvent];
//}

@end
