//
//  SHPuserController.h
//  Closer
//
//  Created by shani hajbi on 3/29/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHControllerContext.h"
@protocol SHPuserControllerDelegate
- (void)didSubscribeToPresenseChannelWithMembers:(PTPusherChannelMembers*)members;
- (void)userDidSubscribeWithId:(NSString*)userId;
- (void)userDidUnSubscribeWithId:(NSString*)userId;
@end

@interface SHPuserController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
@property (nonatomic,weak) id <SHPuserControllerDelegate> delegate;
- (void)connectToPuser;
- (void)disconnectFromPusher;
- (void)listenToPusherCahnnel:(NSString*)channelName eventName:(NSString*)eventName;
- (void)sendEventToChannelWithData:(NSDictionary*)data;
@end
