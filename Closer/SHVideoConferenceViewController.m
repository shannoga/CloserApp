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
    [self addObservers];
    
    self.cameraEnabled = NO;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat participant_diameter = CGRectGetHeight(self.view.bounds)-20;
    CGFloat preview_diameter = participant_diameter/3;

    NSLog(@"self.parentViewController.view - %@",self.parentViewController.view);
    
    //participant view
    
    self.participantVideoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake((screenWidth()-participant_diameter)/2, (CGRectGetHeight(self.view.bounds)-participant_diameter)/2, participant_diameter, participant_diameter)];
    self.participantVideoViewOverlay = [[ooVooVideoView alloc] initWithFrame:CGRectMake(0, 0, participant_diameter, participant_diameter)];
    self.participantVideoView.layer.cornerRadius = self.participantVideoViewOverlay.layer.cornerRadius = participant_diameter/2;
    self.participantVideoView.layer.masksToBounds = self.participantVideoViewOverlay.layer.masksToBounds = YES;
    self.participantVideoView.backgroundColor = self.participantVideoViewOverlay.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.participantVideoView];
    [self.participantVideoView addSubview:self.participantVideoViewOverlay];
    
    
    //preview view
    self.myVideoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake(15, 20, preview_diameter, preview_diameter)];
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

- (void)addObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidBegin:)
                                                 name:OOVOOConferenceDidBeginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidFail:)
                                                 name:OOVOOConferenceDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidEnd:)
                                                 name:OOVOOConferenceDidEndNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidJoin:) name:OOVOOParticipantDidJoinNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(participantStateChanged:)
                                                 name:OOVOOParticipantVideoStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidStart:)
                                                 name:OOVOOVideoDidStartNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidStop:)
                                                 name:OOVOOVideoDidStopNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)conferenceDidBegin:(NSNotification*)notification
{
    self.myParticipantId = notification.userInfo[OOVOOParticipantIdKey];
    [ooVooController sharedController].cameraEnabled = YES;
    [ooVooController sharedController].microphoneEnabled = YES;
    [ooVooController sharedController].speakerEnabled = YES;
    
    [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:self.myParticipantId];
    
    self.cameraEnabled = YES;
    
    self.inConference = YES;
    self.joinButton.enabled = YES;
    [self.joinButton setTitle:NSLocalizedString(@"Leave",@"") forState:UIControlStateNormal];
    
}

- (void)conferenceDidFail:(NSNotification*)notification
{
    self.inConference = NO;
    self.joinButton.enabled = YES;
    [self.joinButton setTitle:NSLocalizedString(@"Join",@"") forState:UIControlStateNormal];
}

- (void)conferenceDidEnd:(NSNotification*)notification
{
    
    self.inConference = NO;
    self.joinButton.enabled = YES;
    [self.joinButton setTitle:NSLocalizedString(@"Join",@"") forState:UIControlStateNormal];
}

- (void)participantStateChanged:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *changedParticipantID = userInfo[OOVOOParticipantIdKey];
        ooVooVideoState state = (ooVooVideoState)[userInfo[OOVOOParticipantStateKey] integerValue];
        
        switch (state) {
            case ooVooVideoUninitialized:
                
                break;
            case ooVooVideoOn:
                [self.participantVideoView associateToID:changedParticipantID];
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
- (void)videoDidStart:(NSNotification*)notification
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

- (void)videoDidStop:(NSNotification*)notification
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)joinLeaveConference:(id)sender
{
    if (!self.inConference) {
        [[ooVooController sharedController] joinConference:@"YourConferenceID" applicationToken:@"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA71BEeMIikqDr26/fzo4oHXZCBM+7/ENSV2i/aq6v/3XKC9pUpDcgtXzhgljwrYopKsEQD+H/ZiMy+0r7X8RMbuL3Mhwx+JwpAdR1brBSnqg==" applicationId:@"12349983350802" participantInfo:@"Shani"];
        self.joinButton.enabled = NO;
    }
    else
    {
        [[ooVooController sharedController] leaveConference];
        self.joinButton.enabled = NO;
        
    }
}



#pragma mark delegate methods



- (void)participantDidLeave:(NSNotification*)notification
{
    NSLog(@"notification = %@",notification);
}

- (void)participantDidJoin:(NSNotification*)notification
{
    NSLog(@"notification = %@",notification);
    NSDictionary *userInfo = notification.userInfo;
    NSString *changedParticipantID = userInfo[OOVOOParticipantIdKey];
    [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:changedParticipantID];
    
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

- (void)dealloc
{
    [self removeObservers];
}
@end
