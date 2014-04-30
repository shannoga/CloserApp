//
//  SHVideoConferenceViewController.m
//  Closer
//
//  Created by shani hajbi on 2/8/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHVideoConferenceViewController.h"
#import "SHNotificationsController.h"
#import "ooVooController.h"
#import "ooVooVideoView.h"
#import "SHOoVooSDKController.h"
#import "SHUser.h"

@interface SHVideoConferenceViewController ()
@property (nonatomic, strong) NSString * myParticipantId;
@property (nonatomic, weak) IBOutlet UIButton *joinButton;
@property (nonatomic, strong) UIImageView *pauseStartPreviewIcon;

@property (nonatomic, strong) ooVooVideoView *myVideoView;
@property (nonatomic, strong) UIView *myVideoViewOverlay;

@property (nonatomic, strong) ooVooVideoView *participantVideoView;
@property (nonatomic, strong) UIView *participantVideoViewOverlay;
@property (nonatomic, strong) UILabel *participantVideoLabel;


@property (nonatomic) BOOL cameraEnabled;
@property (nonatomic) BOOL inConference;

- (IBAction)joinLeaveConference:(id)sender;

@end

@implementation SHVideoConferenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cameraEnabled = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    //participant view
    
    CGFloat participant_diameter = CGRectGetHeight(self.view.bounds)-20;
    CGFloat preview_diameter = participant_diameter/3;
    self.participantVideoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake((screenWidth()-participant_diameter)/2, (CGRectGetHeight(self.view.bounds)-participant_diameter)/2, participant_diameter, participant_diameter)];
    
    //preview view
    self.myVideoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake(15, 20, preview_diameter, preview_diameter)];
    
    self.participantVideoViewOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, participant_diameter, participant_diameter)];
    self.participantVideoView.layer.cornerRadius = self.participantVideoViewOverlay.layer.cornerRadius = participant_diameter/2;
    self.participantVideoView.layer.masksToBounds = self.participantVideoViewOverlay.layer.masksToBounds = YES;
    self.participantVideoView.backgroundColor = self.participantVideoViewOverlay.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.participantVideoView];
    [self.participantVideoView addSubview:self.participantVideoViewOverlay];
    
    
  
    self.myVideoViewOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, preview_diameter, preview_diameter)];
    self.myVideoView.layer.cornerRadius = self.myVideoViewOverlay.layer.cornerRadius =preview_diameter / 2;
    self.myVideoView.layer.masksToBounds = self.myVideoViewOverlay.layer.masksToBounds = YES;
    self.myVideoView.backgroundColor = self.myVideoViewOverlay.backgroundColor =  [UIColor grayColor];
    [self.view addSubview:self.myVideoView];
    [self.myVideoView addSubview:self.myVideoViewOverlay];
    
    UIGestureRecognizer *togglePreviewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePreview:)];
    [self.myVideoView addGestureRecognizer:togglePreviewRecognizer];
    
    self.pauseStartPreviewIcon =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"138-Pause"] highlightedImage:[UIImage imageNamed:@"139-Play"]];
    [self.myVideoView addSubview:self.pauseStartPreviewIcon];
    [self updateStartPauseButton];
    
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self joinConference];

}

- (void)addVideoView
{
    CGFloat participant_diameter = CGRectGetHeight(self.view.bounds)-20;
    CGFloat preview_diameter = participant_diameter/3;
    self.participantVideoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake((screenWidth()-participant_diameter)/2, (CGRectGetHeight(self.view.bounds)-participant_diameter)/2, participant_diameter, participant_diameter)];
    
    //preview view
    self.myVideoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake(15, 20, preview_diameter, preview_diameter)];
}


- (void)startListeningToSessionEvents
{
    [self.controllerContext.sdkController startListeningToOoVooSessionHandler:^(SHSDKConferenseEvent sessionEvent, NSDictionary *eventInfo) {
        switch (sessionEvent) {
            case SHSDKConferenseEventDidBegin:
                [self conferenceDidBegin:eventInfo[OOVOOParticipantIdKey]];
                break;
            case SHSDKConferenseEventDidFail:
                [self conferenceDidFail];
                break;
            case SHSDKConferenseEventDidEnd:
                [self conferenceDidEnd];
                break;
            case SHSDKConferenseEventParticipantDidJoin:
            {
                NSString *changedParticipantID = eventInfo[OOVOOParticipantIdKey];
                [self participantDidJoin:changedParticipantID];
            }
                break;
            case SHSDKConferenseEventParticipantDidLeave:
            {
                NSString *changedParticipantID = eventInfo[OOVOOParticipantIdKey];
                [self participantDidLeave:changedParticipantID];
            }
                break;
                
            default:
                break;
        }
    }];
}

- (void)startListeningToVideoEvents
{
    [self.controllerContext.sdkController startListeningToOoVooVideoHandler:^(SHSDKVideoEvent videoEvent, NSDictionary *eventInfo) {
        switch (videoEvent) {
            case SHSDKVideoEventVideoStateChanged:
            {
                NSString *changedParticipantID = eventInfo[OOVOOParticipantIdKey];
                ooVooVideoState state = (ooVooVideoState)[eventInfo[OOVOOParticipantStateKey] integerValue];
                [self participantStateChanged:state changedParticipantId:changedParticipantID];
            }
                
            case SHSDKVideoEventVideoStarted:
                [self videoDidStart];
                break;
            case SHSDKVideoEventVideoStoped:
                [self videoDidStop];
                break;
            case SHSDKVideoEventSpeakerMuted:
                
                break;
            case SHSDKVideoEventSpeakerUnmuted:
                
                break;
            case SHSDKVideoEventMicrophoneMuted:
                
                break;
            case SHSDKVideoEventMicrophoneUnmuted:
                
                break;
                
            default:
                break;
        }
    }];
}




- (void)conferenceDidBegin:(NSString*)myId
{
    self.myParticipantId = myId;
    [ooVooController sharedController].cameraEnabled = YES;
    [ooVooController sharedController].microphoneEnabled = YES;
    [ooVooController sharedController].speakerEnabled = YES;
    
    [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:self.myParticipantId];
    
    self.cameraEnabled = YES;
    
    self.inConference = YES;
    self.joinButton.enabled = YES;
    [self.joinButton setTitle:NSLocalizedString(@"Leave",@"") forState:UIControlStateNormal];
    
}

- (void)conferenceDidFail
{
    self.inConference = NO;
    self.joinButton.enabled = YES;
    [self.joinButton setTitle:NSLocalizedString(@"Join",@"") forState:UIControlStateNormal];
}

- (void)conferenceDidEnd
{
    self.inConference = NO;
    self.joinButton.enabled = YES;
    [self.joinButton setTitle:NSLocalizedString(@"Join",@"") forState:UIControlStateNormal];
}

- (void)participantStateChanged:(ooVooVideoState)state changedParticipantId:(NSString*)changedParticipantId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case ooVooVideoUninitialized:
                
                break;
            case ooVooVideoOn:
                [self.participantVideoView associateToID:changedParticipantId];
                [self.participantVideoView showVideo:YES];
                self.participantVideoViewOverlay.hidden = YES;
                
                break;
            case ooVooVideoOff:
                [self.participantVideoView clear];
                self.participantVideoViewOverlay.hidden = NO;
                break;
            case ooVooVideoPaused:
                [self.participantVideoView clear];
                
                break;
                
        }
        
    });
}
- (void)videoDidStart
{
    // NSString *participantId = notification.userInfo[OOVOOParticipantIdKey];
    // if([participantId isEqualToString:self.myParticipantId])
    //   {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.myVideoView associateToID:self.myParticipantId];
        [self.myVideoView showVideo:YES];
        [self updateStartPauseButton];
    });
    // }
}

- (void)videoDidStop
{
    // NSString *participantId = notification.userInfo[OOVOOParticipantIdKey];
    // if([participantId isEqualToString:self.myParticipantId])
    //   {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myVideoView clear];
        [self updateStartPauseButton];
    });
    // }
}


- (IBAction)joinLeaveConference:(id)sender
{
    if (!self.inConference) {
        [self joinConference];
        self.joinButton.enabled = NO;
    }
    else
    {
        [[ooVooController sharedController] leaveConference];
        self.joinButton.enabled = NO;
        
    }
}

- (void)joinConference
{
    [self startListeningToSessionEvents];
    [self startListeningToVideoEvents];
    [[ooVooController sharedController] joinConference:@"YourConferenceID"  participantId:[[SHUser currentUser] objectId] participantInfo:[[SHUser currentUser] username]];
}



#pragma mark delegate methods



- (void)participantDidLeave:(NSString*)changedParticipantId
{
    self.joinButton.enabled = NO;
}

- (void)participantDidJoin:(NSString*)changedParticipantId
{
    [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:changedParticipantId];
}


#pragma mark user actions

- (void)togglePreview:(UITapGestureRecognizer*)recognizer
{
    self.cameraEnabled = !self.cameraEnabled;
    [[ooVooController sharedController] setCameraEnabled:self.cameraEnabled];
    [[ooVooController sharedController] setMicrophoneEnabled:self.cameraEnabled];
    [[ooVooController sharedController] setSpeakerEnabled:self.cameraEnabled];
}

- (void)updateStartPauseButton
{
    self.myVideoViewOverlay.hidden = self.cameraEnabled;
    self.pauseStartPreviewIcon.highlighted = !self.cameraEnabled;
    CGFloat imageWidth = self.pauseStartPreviewIcon.image.size.width;
    CGFloat imageHeight = self.pauseStartPreviewIcon.image.size.height;
    
    [UIView animateWithDuration:.5 animations:^{
        if (self.cameraEnabled)
        {
            self.pauseStartPreviewIcon.frame = CGRectMake((CGRectGetWidth(self.myVideoView.frame) - imageWidth/2)/2, (CGRectGetHeight(self.myVideoView.frame) - (imageHeight/2) - 4), imageWidth/2, imageHeight/2);
            
        }
        else
        {
            self.pauseStartPreviewIcon.frame = CGRectMake((CGRectGetWidth(self.myVideoView.frame) - imageWidth)/2, (CGRectGetHeight(self.myVideoView.frame) - imageHeight)/2, imageWidth, imageHeight);
        }
    }];
    
    
}



#pragma mark dealloc


@end
