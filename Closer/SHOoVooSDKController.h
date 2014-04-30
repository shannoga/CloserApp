//
//  SHOoVooSDKController.h
//  Closer
//
//  Created by shani hajbi on 3/23/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHControllerContext.h"

typedef  NS_ENUM(NSUInteger, SHSDKConferenseEvent)
{
    SHSDKConferenseEventDidBegin,
    SHSDKConferenseEventDidFail,
    SHSDKConferenseEventDidEnd,
    SHSDKConferenseEventParticipantDidJoin,
    SHSDKConferenseEventParticipantDidLeave,
};

typedef  NS_ENUM(NSUInteger, SHSDKVideoEvent)
{
    SHSDKVideoEventVideoStateChanged,
    SHSDKVideoEventVideoStarted,
    SHSDKVideoEventVideoStoped,
    SHSDKVideoEventMicrophoneMuted,
    SHSDKVideoEventMicrophoneUnmuted,
    SHSDKVideoEventSpeakerMuted,
    SHSDKVideoEventSpeakerUnmuted,
};

@interface SHOoVooSDKController : NSObject
@property (nonatomic,strong) SHControllerContext *context;
@property (nonatomic) BOOL oovooSDKLoggedIn;
@property (nonatomic) BOOL hasActiveSession;
- (void)loginToOoVooSDKWithSuccess:(void (^)(ooVooInitResult result))initResult;
- (void)prepareForLogout;

typedef void(^SHSDKSessionHandler)(SHSDKConferenseEvent sessionEvent, NSDictionary *eventInfo);
typedef void(^SHSDKVideoHandler)(SHSDKVideoEvent videoEvent, NSDictionary *eventInfo);

@property (nonatomic) PlayerMode playerMode;
@property (nonatomic) BOOL playerIsAdmin;

- (void)startListeningToOoVooSessionHandler:(SHSDKSessionHandler)sessionHandler;
- (void)startListeningToOoVooVideoHandler:(SHSDKVideoHandler)videoHandler;

@end
