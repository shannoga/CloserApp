//
//  SHNotificationsController.m
//  Closer
//
//  Created by shani hajbi on 2/8/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHNotificationsController.h"
#import "ooVooController.h"

@implementation SHNotificationsController


- (id)init
{
    self = [super init];
    if (self) {
        //conference
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conferenceDidBegin:) name:OOVOOConferenceDidBeginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conferenceDidFail:) name:OOVOOConferenceDidFailNotification object:nil];
//
//        //participants
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:@"OOVOOParticipantDidLeaveNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantVideoStateDidChange:) name:@"OOVOOParticipantVideoStateDidChangeNotification" object:nil];
//        
//        //video
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:@"OOVOOVideoDidStartNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:@"OOVOOVideoDidStopNotification" object:nil];
//
//        //audio
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidMuteMicrophone:) name:@"OOVOOUserDidMuteMicrophoneNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidUnmuteMicrophone:) name:@"OOVOOUserDidUnmuteMicrophoneNotification" object:nil];
//        
//        //speaker
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidMuteSpeaker:) name:@"OOVOOUserDidMuteSpeakerNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidUnmuteSpeaker:) name:@"OOVOOUserDidUnmuteSpeakerNotification" object:nil];

    }
    return self;
}

#pragma mark pconference
- (void)conferenceDidBegin:(NSNotification*)notification
{
    //[self.delegate conferenceCreated:YES error:nil];
}

- (void)conferenceDidFail:(NSNotification*)notification
{
   // [self.delegate conferenceCreated:NO error:nil];

}

#pragma mark participant joind left

- (void)participantDidLeave:(NSNotification*)notification
{
    
}

- (void)participantVideoStateDidChange:(NSNotification*)notification
{
    
}

#pragma mark video start stop
- (void)videoDidStart:(NSNotification*)notification
{
    
}

- (void)videoDidStop:(NSNotification*)notification
{
    
}


#pragma mark audio start stop
- (void)userDidMuteMicrophone:(NSNotification*)notification
{
    
}

- (void)userDidUnmuteMicrophone:(NSNotification*)notification
{
    
}

#pragma mark speaker start stop
- (void)userDidMuteSpeaker:(NSNotification*)notification
{
    
}

- (void)userDidUnmuteSpeaker:(NSNotification*)notification
{
    
}







@end
