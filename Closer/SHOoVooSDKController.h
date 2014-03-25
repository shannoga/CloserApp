//
//  SHOoVooSDKController.h
//  Closer
//
//  Created by shani hajbi on 3/23/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHControllerContext.h"

@interface SHOoVooSDKController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
@property (nonatomic) BOOL oovooSDKLoggedIn;

- (void)loginToOoVooSDKWithSuccess:(void (^)(ooVooInitResult result))initResult;

@end
