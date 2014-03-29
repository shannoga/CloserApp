//
//  SHOoVooSDKController.m
//  Closer
//
//  Created by shani hajbi on 3/23/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHOoVooSDKController.h"
#import "SHControllerContext.h"

@implementation SHOoVooSDKController

- (void)loginToOoVooSDKWithSuccess:(void (^)(ooVooInitResult result))initSDKResult
{
    if (self.oovooSDKLoggedIn) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ooVooInitResult initResult = [[ooVooController sharedController] initSdk:@"12349983350802" applicationToken:@"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkilaNavBrtoMUT4vK%2FdxLgQBM%2B%2FGrf8PeRbTs6MY6H7hgDJAW0RL%2FILa%2BhAYr95sU7CYvM1nDd1JuhCTZvn2g8GsN6YSPpkUy7G3OKPvyEQ%3D%3D" baseUrl:@"https://api-sdk.dev.oovoo.com/"];
        
        if (initResult != ooVooInitResultOk) {
            NSLog(@"Error login to ooVoo SDK - %i",initResult);
            [self setOovooSDKLoggedIn:NO];
        }
        else
        {
            NSLog(@"logged in with ooVoo SDK version %@",[ooVooController sharedController].sdkVersion);
            [self setOovooSDKLoggedIn:YES];
        }
        
        
        if (initSDKResult) {
            initSDKResult(initResult);
        }
    });
}

@end
