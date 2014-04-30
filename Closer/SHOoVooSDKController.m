//
//  SHOoVooSDKController.m
//  Closer
//
//  Created by shani hajbi on 3/23/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHOoVooSDKController.h"
#import "SHControllerContext.h"
@interface SHOoVooSDKController()
@property (nonatomic, copy) SHSDKSessionHandler sessionHandler;
@property (nonatomic, copy) SHSDKVideoHandler videoHandler;
@end

@implementation SHOoVooSDKController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self addObservers];
    }
    return self;
}

- (void)loginToOoVooSDKWithSuccess:(void (^)(ooVooInitResult result))initSDKResult
{
    if (self.oovooSDKLoggedIn) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ooVooInitResult initResult = [[ooVooController sharedController] initSdk:@"12349983350802" applicationToken:@"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkilaNavBrtoMUT4vK%2FdxLgQBM%2B%2FGrf8PeRbTs6MY6H7hgDJAW0RL%2FILa%2BhAYr95sU7CYvM1nDd1JuhCTZvn2g8GsN6YSPpkUy7G3OKPvyEQ%3D%3D" baseUrl:@"https://api-sdk.dev.oovoo.com/"];
        
        if (initResult != ooVooInitResultOk) {
            DDLogError(@"Error login to ooVoo SDK - %i",initResult);
            [self setOovooSDKLoggedIn:NO];
        }
        else
        {
            DDLogInfo(@"logged in with ooVoo SDK version %@",[ooVooController sharedController].sdkVersion);
            [self setOovooSDKLoggedIn:YES];
        }
        
        
        if (initSDKResult) {
            initSDKResult(initResult);
        }
    });
}


- (void)addObservers
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(updateSessionHandler:)
                               name:OOVOOConferenceDidBeginNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateSessionHandler:)
                               name:OOVOOConferenceDidFailNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateSessionHandler:)
                               name:OOVOOConferenceDidEndNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateSessionHandler:)
                               name:OOVOOParticipantDidJoinNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateSessionHandler:)
                               name:OOVOOParticipantDidLeaveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOParticipantVideoStateDidChangeNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOVideoDidStartNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOVideoDidStopNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOUserDidMuteMicrophoneNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOUserDidUnmuteMicrophoneNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOUserDidMuteSpeakerNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(updateVideoHandler:)
                               name:OOVOOUserDidUnmuteSpeakerNotification
                             object:nil];

}

- (void)updateSessionHandler:(NSNotification*)notification
{
    SHSDKConferenseEvent event = SHSDKConferenseEventDidBegin;
    if (notification.name == OOVOOConferenceDidBeginNotification) {
        event = SHSDKConferenseEventDidBegin;
    }else if (notification.name == OOVOOConferenceDidFailNotification){
        event = SHSDKConferenseEventDidFail;
    }else if (notification.name == OOVOOConferenceDidEndNotification){
        event = SHSDKConferenseEventDidEnd;
    }else if (notification.name == OOVOOParticipantDidJoinNotification){
        event = SHSDKConferenseEventParticipantDidJoin;
    }else if (notification.name == OOVOOParticipantDidLeaveNotification){
        event = SHSDKConferenseEventParticipantDidLeave;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sessionHandler) {
            self.sessionHandler(event,notification.userInfo);
        }
    });
   
}

- (void)updateVideoHandler:(NSNotification*)notification
{
    SHSDKVideoEvent event = SHSDKVideoEventVideoStarted;

    if (notification.name == OOVOOParticipantVideoStateDidChangeNotification){
        event = SHSDKVideoEventVideoStateChanged;
    }else if (notification.name == OOVOOVideoDidStartNotification){
        event = SHSDKVideoEventVideoStarted;
    }else if (notification.name == OOVOOVideoDidStopNotification){
        event = SHSDKVideoEventVideoStoped;
    }else if (notification.name == OOVOOUserDidMuteMicrophoneNotification){
        event = SHSDKVideoEventMicrophoneMuted;
    }else if (notification.name == OOVOOUserDidUnmuteMicrophoneNotification){
        event = SHSDKVideoEventMicrophoneUnmuted;
    }else if (notification.name == OOVOOUserDidMuteSpeakerNotification){
        event = SHSDKVideoEventSpeakerMuted;
    }else if (notification.name == OOVOOUserDidUnmuteSpeakerNotification){
        event = SHSDKVideoEventSpeakerUnmuted;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.videoHandler) {
            self.videoHandler(event,notification.userInfo);
        }
    });
}

- (void)startListeningToOoVooSessionHandler:(SHSDKSessionHandler)sessionHandler
{
    self.sessionHandler = sessionHandler;
}

- (void)startListeningToOoVooVideoHandler:(SHSDKVideoHandler)videoHandler
{
    self.videoHandler = videoHandler;
}



- (void)prepareForLogout
{
#warning Impliment
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
