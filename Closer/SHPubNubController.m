//
//  SHPubNubController.m
//  Closer
//
//  Created by shani hajbi on 4/9/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHPubNubController.h"
#import "SHUser.h"
#import "SHUserProfileController.h"

#define BACKGROUND_TASK_TIMER_DURATION 10
#define CALL_TIMEOUT 10

NSString *const kEventType = @"eventType";
NSString *const kClientEventName = @"client-event";

NSString *const kOnline = @"online";
NSString *const kSenderId = @"sender_id";
NSString *const kSenderName = @"sender";
NSString *const kReciverId = @"reciver_id";
NSString *const kCalling = @"calling";
NSString *const kCallResult = @"call_result";

@interface SHPubNubController()<PNDelegate>
@property (nonatomic,strong) PNChannel *groupChannel;
@property (nonatomic,strong) NSMutableDictionary *groupMembers;
@property (nonatomic,strong) NSTimer *backgroundTaskTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) UIBackgroundTaskIdentifier timerBackgroundTask;
@property (nonatomic,copy) SHCallResultHandler callResultHandler;
@property (nonatomic,strong) NSTimer * callingTimer;
@property (nonatomic,strong) NSString * channelName;


@end


@implementation SHPubNubController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBackgroundTaskTimer:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopBackgroundTaskTimer:) name:UIApplicationDidBecomeActiveNotification object:nil];
        self.groupMembers = [NSMutableDictionary dictionary];
        [self listenToMesseges];
        [self listenToPresence];
        [self listenTo];
        [self setUpPubNub];
 
    }
    return self;
}

- (void)setUpPubNub
{
    [PubNub setDelegate:self];
    [PubNub setClientIdentifier:[SHUser currentUser].objectId];
    
    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"  publishKey:@"pub-c-bb9e2ac7-110a-437b-9d73-7a4d40baf911" subscribeKey:@"sub-c-f3690ad4-bf65-11e3-8337-02ee2ddab7fe" secretKey:@"sec-c-ZTM4MDBjMmEtYmMzMC00NzM2LTliOTctMDI4MzFjZWJlNGJl"];
    
    // Set the presence heartbeat to 5s
    myConfig.presenceHeartbeatTimeout = 5;
    
    [PubNub setConfiguration:myConfig];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        DDLogInfo(@"Did connect to PubNub");
    } errorBlock:^(PNError *connectionError) {
        if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
            PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
        }
        
        UIAlertView *connectionErrorAlert = [UIAlertView new];
        connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                      [connectionError localizedDescription],
                                      NSStringFromClass([self class])];
        connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                        [connectionError localizedFailureReason],
                                        [connectionError localizedRecoverySuggestion]];
        [connectionErrorAlert addButtonWithTitle:@"OK"];
        [connectionErrorAlert show];
    }];
    
    
}

- (void)sweepMembers
{
    
}

- (void)updateGroupMember:(NSString *)objectId {
    self.groupMembers[objectId] = @([NSDate timeIntervalSinceReferenceDate]);
}

- (void)addGroupMember:(NSString *)objectId {
    self.groupMembers[objectId] = @([NSDate timeIntervalSinceReferenceDate]);
}

- (PNChannel*)groupChannel
{
    if (!_groupChannel) {
        PFObject *group = self.context.userProfileController.activeGroup;
        _groupChannel = [PNChannel channelWithName:group[@"groupName"] shouldObservePresence:YES];
    }
    return _groupChannel;
}

- (void)subscribeToGroupChannel
{
    [PubNub subscribeOnChannel:self.groupChannel withClientState:@{@"user_name":[SHUser currentUser].username,@"object_id":[SHUser currentUser].objectId} andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        DDLogVerbose(@"%i",state);
        DDLogVerbose(@"%@",self.groupChannel.participants);
        if (error) {
            DDLogVerbose (@"error = %@:",error.description);
        }
//        [PubNub requestParticipantsListForChannel:self.groupChannel clientIdentifiersRequired:YES withCompletionBlock:^(NSArray *part, PNChannel *channel, PNError *error) {
//            DDLogInfo(@"");
//        }];
    }];
}

- (void)unsubscibeFromGroupChannel
{
    [PubNub unsubscribeFromChannel:self.groupChannel withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        
    }];
}


- (void)listenToMesseges
{

[[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                     withBlock:^(PNMessage *message) {
//                                                         NSString *objectId = event.client.identifier;
//                                                         
//                                                         // ignore yourself
//                                                         if ([objectId isEqualToString:[PubNub clientIdentifier]]) {
//                                                             return;
//                                                         }
                                                         SHEventType eventType = [message.message[kEventType] integerValue];
                                                         switch (eventType) {
                                                             case SHEventTypeCalling:
                                                                 [self handleCallingEvent:message];
                                                                 break;
                                                             case SHEventTypeMessgae:
                                                                 break;
                                                                 
                                                             default:
                                                                 break;
                                                         }
                                                         
                                                         DDLogCVerbose(@"message: %@", message.message);
                                                         
 
                                                     }];
}

- (void)handleCallingEvent:(PNMessage*)message
{
    if ([message.message[kReciverId] isEqualToString:[SHUser currentUser].objectId]) {
        if ([message.message[kCalling] boolValue]) {
            //incoming call
            
            NSString *callerId = message.message[kSenderId];
            
            [self handleIncomingCallFromEvent:message answerHandler:^(SHCallResult callResult) {
                //send answer event
                [self sendMessege:@{kEventType:@(SHEventTypeCalling) ,kSenderName:[PFUser currentUser].username,kSenderId:[PFUser currentUser].objectId,kReciverId:callerId, kCalling:@(NO),kCallResult:@(callResult)}];
            }];
        }
        else
        {
            //answer
            [self.callingTimer invalidate];
            if (self.callResultHandler)
            {
                self.callResultHandler([message.message[kCallResult] integerValue],nil);
            }
        }
    }
}


- (void)handleIncomingCallFromEvent:(PNMessage*)message answerHandler:(void (^)(SHCallResult callResult))answerHandler
{
    UIApplication *application = [UIApplication sharedApplication];
    
    //incoming call
    if ([application applicationState] == UIApplicationStateBackground)
    {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        NSString *pushString = NSLocalizedString(@"%@ invites you to play",nil);
        NSString *senderName = message.message[kSenderName];
        localNotif.alertBody = [NSString stringWithFormat:pushString,senderName];
        localNotif.alertAction = @"Accept";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [application scheduleLocalNotification:localNotif];
    }
    else
    {
        DDLogVerbose(@"Recieved game invitation");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate userDidCall:message.message[kSenderId] answerHandler:answerHandler];
        });
    }
    
}


- (void)listenTo
{
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *connectionError) {
                                                            DDLogInfo(@"{BLOCK} client identifier %@", [PubNub clientIdentifier]);
                                                        }];
}

- (void)listenToPresence
{
    
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
        NSString *objectId = event.client.identifier;
        
        // ignore yourself
        if ([objectId isEqualToString:[PubNub clientIdentifier]]) {
            return;
        }
        
        NSString *eventString;
        if (event.type == PNPresenceEventJoin) {
            [self.delegate userDidSubscribeWithId:objectId];

            eventString = @"Join";
        } else if (event.type == PNPresenceEventLeave) {
            eventString = @"Leave";
            [self.delegate userDidUnSubscribeWithId:objectId];
        } else if (event.type == PNPresenceEventTimeout) {
            eventString = @"Timeout";
        }
        
        if (![eventString isEqualToString:@"Timeout"]) {
            DDLogInfo(@"eventString = %@",eventString);
            NSString * alreadyExists = [self.groupMembers objectForKey:objectId];
            if (alreadyExists) {
                DDLogInfo(@"Heard from an existing user: %@", objectId);
                [self updateGroupMember:objectId];
            } else {
                DDLogInfo(@"Heard from a new user: %@", objectId);
                [self addGroupMember:objectId];
            }
        }
    }];
}




- (NSNumber*)shouldResubscribeOnConnectionRestore
{
    return @(YES);
}



#pragma -mark calling and messaging

- (void)sendMessege:(NSDictionary*)dic
{
    [PubNub sendMessage:dic toChannel:self.groupChannel withCompletionBlock:^(PNMessageState state, id obj) {
        switch (state) {
            case PNMessageSending:
                
                break;
            case PNMessageSent:
                
                break;
            case PNMessageSendingError:
                
                break;
            default:
                break;
        }
    }];
}


- (void)callUserWithObjectId:(NSString*)objectId WithCallResultHandler:(SHCallResultHandler)callResultHandler
{
    self.callResultHandler = callResultHandler;
    NSDictionary *message = @{kEventType:@(SHEventTypeCalling),kSenderName:[PFUser currentUser].username,kSenderId:[PFUser currentUser].objectId,kReciverId:objectId, kCalling:@(YES),kCallResult:@(SHCallResultUnknown)};
    if (YES){//user.online) {
        [self startCallingTimer];
        [self sendMessege:message];
    }
    else
    {
        //alert user that the user is offline and full back to push notification
        [self sendPushToUser:objectId withData:message];
    }
}

- (void)startCallingTimer
{
    self.callingTimer = [NSTimer scheduledTimerWithTimeInterval:CALL_TIMEOUT target:self selector:@selector(callTimeOut:) userInfo:nil repeats:NO];
}

- (void)callTimeOut:(NSTimer*)timer
{
    [timer invalidate];
    if(self.callResultHandler)
    {
        self.callResultHandler(SHCallResultTimedOut,nil);
    }
    
}

- (void)sendPushToUser:(NSString*)objectId withData:(NSDictionary*)data
{
    PFQuery *innerQuery = [SHUser query];
    [innerQuery whereKey:@"objectId" equalTo:objectId];
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" matchesQuery:innerQuery];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    NSString *pushString = NSLocalizedString(@"%@ invites you to play",nil);
    [push setMessage:[NSString stringWithFormat:pushString,[PFUser currentUser].username]];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
        {
            DDLogError(@"error = %@", error.userInfo);
        }
        else if (succeeded)
        {
            DDLogInfo(@"push sent to : %@", objectId);
            
        }
    }];
}




//- (void)connectToPuserAndSubscribeToGroupChannel:(NSString*)channelName
//{
//    
//}
//- (void)disconnectFromPusher
//{
//    
//}
//- (void)sendEventToChannelWithData:(NSDictionary*)data
//{
//    
//}
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    PNLog(PNLogGeneralLevel,self,@"PubNub client received message: %@", message);
}



- (void)beginBackgroundConnectionTask
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DDLogVerbose(@"Background task ended from beginBackgroundTaskWithExpirationHandler");
        [self endBackgroundTasks:self.backgroundTaskTimer];
    }];
}

- (void)beginBackgroundTimerTask
{
    self.timerBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DDLogVerbose(@"Background timer task ended from beginBackgroundTaskWithExpirationHandler");
        [self endBackgroundTasks:self.backgroundTaskTimer];
    }];
}


- (void)endBackgroundTasks:(NSTimer*)timer
{
    DDLogVerbose(@"Background task ended from timer");
    
    if (timer) {
        [timer invalidate];
    }
    [self unsubscibeFromGroupChannel];
    [PubNub disconnect];
    
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
    [[UIApplication sharedApplication] endBackgroundTask: self.timerBackgroundTask];
    self.timerBackgroundTask = UIBackgroundTaskInvalid;
    
}

- (void)startBackgroundTaskTimer:(NSNotification*)notification
{
    DDLogVerbose(@"Went to background, starting background timer");
    [self beginBackgroundTimerTask];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run function methodRunAfterBackground
        self.backgroundTaskTimer = [NSTimer timerWithTimeInterval:BACKGROUND_TASK_TIMER_DURATION target:self selector:@selector(endBackgroundTasks:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.backgroundTaskTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)stopBackgroundTaskTimer:(NSNotification*)notification
{
    DDLogVerbose(@"Returned to fourground stoping background timer");
    
    [[UIApplication sharedApplication] endBackgroundTask: self.timerBackgroundTask];
    self.timerBackgroundTask = UIBackgroundTaskInvalid;
    [self.backgroundTaskTimer invalidate];
    self.backgroundTaskTimer = nil;
    if ([SHUser currentUser].isAuthenticated && self.context.userProfileController.activeGroup) {
        [self subscribeToGroupChannel];
    }
}

- (void)prepareForLogout
{
    [self unsubscibeFromGroupChannel];
    [PubNub disconnect];
    [self.groupMembers removeAllObjects];
    self.groupChannel = nil;
}

@end
