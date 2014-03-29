//
//  SHPuserController.h
//  Closer
//
//  Created by shani hajbi on 3/29/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHControllerContext.h"

@interface SHPuserController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
- (void)connectToPuser;
- (void)disconnectFromPusher;
- (void)listenToPusherCahnnel:(NSString*)channelName eventName:(NSString*)eventName;

@end
