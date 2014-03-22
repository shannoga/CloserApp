//
//  SHNotificationsController.h
//  Closer
//
//  Created by shani hajbi on 2/8/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHNotificationsControllerDelegate
- (void)conferenceCreated:(BOOL)success error:(NSError*)error;
- (void)participantDidJoin;
- (void)participantVideoChanged:(BOOL)started;
- (void)participantAudioChanged:(BOOL)started;
- (void)participantSpeakerChanged:(BOOL)started;
@end


@interface SHNotificationsController : NSObject
@property (nonatomic, weak) id <SHNotificationsControllerDelegate> delegate;
@end
