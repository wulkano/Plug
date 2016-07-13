//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <AFNetworking/AFNetworking.h>
#import "CommonCrypto/CommonCrypto.h"
#import "SLColorArt.h"
#import "NSObject+SPInvocationGrabbing.h"
#import "SPMediaKeyTap.h"

@interface AFImageResponseSerializer (CustomInit)
+ (instancetype)sharedSerializer;
@end