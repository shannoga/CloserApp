//
//  SHPubNubController.h
//  Closer
//
//  Created by shani hajbi on 4/9/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHControllerContext.h"

typedef  NS_ENUM(NSUInteger, SHCallResult)
{
    SHCallResultAnswered,
    SHCallResultRejected,
    SHCallResultTimedOut,
    SHCallResultUnknown
};

typedef  NS_ENUM(NSUInteger, SHEventType)
{
    SHEventTypeCalling,
    SHEventTypeMessgae,
};

@protocol SHPubNubControllerDelegate
- (void)didSubscribeToPresenseChannelWithMembers:(PTPusherChannelMembers*)members;
- (void)userDidSubscribeWithId:(NSString*)userId;
- (void)userDidUnSubscribeWithId:(NSString*)userId;
- (void)userDidCall:(NSString*)userId answerHandler:(void (^)(SHCallResult callResult))callResult;

@end

@interface SHPubNubController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
@property (nonatomic,weak) id <SHPubNubControllerDelegate> delegate;
@property (nonatomic) BOOL isConnected;

typedef void(^SHCallResultHandler)(SHCallResult callResult, NSError *error);

//- (void)connectToPuserAndSubscribeToGroupChannel:(NSString*)channelName;
//- (void)disconnectFromPusher;
//- (void)sendEventToChannelWithData:(NSDictionary*)data;
- (void)subscribeToGroupChannel;
- (void)unsubscibeFromGroupChannel;
- (void)prepareForLogout;
- (void)callUserWithObjectId:(NSString*)objectId WithCallResultHandler:(SHCallResultHandler)callResultHandler;
@end
