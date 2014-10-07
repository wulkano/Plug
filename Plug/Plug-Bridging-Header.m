//
//  Plug-Bridging-Header.m
//  Plug
//
//  Created by Alex Marchant on 10/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

#import "Plug-Bridging-Header.h"

@implementation AFImageResponseSerializer (CustomInit)
+ (instancetype)sharedSerializer {
    return [AFImageResponseSerializer serializer];
}
@end