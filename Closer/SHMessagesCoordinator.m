//
//  SHGameCoordinator.m
//  Closer
//
//  Created by shani hajbi on 2/24/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHMessagesCoordinator.h"

NSString *const kmessageType = @"messageType";
NSString *const kmessage = @"message";
NSString *const kstepIndex = @"stepIndex";
NSString *const kmessageTimeStamp = @"messageTimeStamp";
NSString *const kmenuItemIndex = @"menuItemIndex";

@interface SHMessagesCoordinator()
@property (nonatomic) BOOL isActive;
@property (nonatomic, copy) SHCoordinatorMenuHandler menuHandler;
@property (nonatomic, copy) SHCoordinatorProgressHandler progressHandler;
@property (nonatomic, copy) SHCoordinatorFeedbackHandler feedbackHandler;

@end

@implementation SHMessagesCoordinator

+ (id)sharedCoordinator {
    static SHMessagesCoordinator *sharedCoordinator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoordinator = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedCoordinator selector:@selector(parseIncomingMessage:) name:OOVOOInCallMessageNotification object:nil];
    });
    return sharedCoordinator;
}


- (void)sendMenuProgressMessageToChild:(MenuMessage)messegeType stepIndex:(NSUInteger)stepIndex
{
    
}


- (void)sendMessageOfType:(MessageType)messegeType message:(NSUInteger)message index:(NSInteger)index
{
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    NSDictionary *messageDic;
    switch (messegeType) {
        case MessageTypeMenu:
            messageDic = @{kmessageType:messegeType ? @(messegeType) : @(0),
                           kmessage:message ? @(message) : @(0),
                           kmenuItemIndex:index ? @(index) : @(0),
                           kmessageTimeStamp:@(interval)};
            break;
        case MessegeTypeProgress:
            messageDic = @{kmessageType:messegeType ? @(messegeType) : @(0),
                           kmessage:message ? @(message) : @(0),
                           kstepIndex:index ? @(index) :@(0),
                           kmessageTimeStamp:@(interval)};
            break;
        case MessageTypeFeedback:
            messageDic = @{kmessageType:messegeType ? @(messegeType) : @(0),
                           kmessage:message ? @(message) : @(0),
                           kmessageTimeStamp:@(interval)};
            break;
            
        default:
            break;
    }
    
    NSString *messageJsonString = [self serializeMessageDic:messageDic];
    if (messageJsonString)
    {
        [self sendMessege:messageJsonString];
    }
    
}

- (NSString*)serializeMessageDic:(NSDictionary*)messageDic
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        DDLogError(@"Got an error: %@", error);
        return nil;
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
    
}

- (void)sendGamePrizeMessageToChild:(FeedbackMessage)messegeType
{


}

- (void)sendMessege:(NSString *)message
{
    if ([[ooVooController sharedController] inCallMessagesPermitted] && [[ooVooController sharedController] cameraEnabled] ) {
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
         [[ooVooController sharedController] sendMessage:data toParticipantID:nil];
        DDLogDebug(@"message sent = %@",message);
    }
    else
    {
        DDLogError(@"can not send message = %@",message);
    }
}

#pragma  mark - parseIncomingMessage

- (void)parseIncomingMessage:(NSNotification*)notification
{
    NSData *messageData = notification.userInfo[OOVOOParticipantInfoKey];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&error];
    DDLogDebug(@"incoming messege = %@",dictionary);
    [self handleIncomingMessageDic:dictionary];
}

- (void)parseTestIncomingMessage:(NSData*)messageData
{
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&error];
    DDLogInfo(@"dic = %@",dictionary);
    [self handleIncomingMessageDic:dictionary];
}


- (void)handleIncomingMessageDic:(NSDictionary*)messageDic
{
    MessageType messageType = [messageDic[kmessageType] integerValue];
    NSUInteger message = [messageDic[kmessage] integerValue];
    
    switch (messageType) {
        case MessageTypeMenu:
        {
            if (!self.menuHandler) return;
            NSUInteger mainGame = [messageDic[kmenuItemIndex] integerValue];
            self.menuHandler(message,mainGame);
        }
            break;
        case MessegeTypeProgress:
        {
            if (!self.progressHandler) return;
            NSUInteger stepIndex = [messageDic[kstepIndex] integerValue];
            self.progressHandler(message,stepIndex);
        }
            break;
        case MessageTypeFeedback:
            if (!self.feedbackHandler) return;
            self.feedbackHandler(message);
            break;
            
        case MessageTypeNone:
            break;
    }
}


- (void)startUpdatingAdminMenuMessages:(SHCoordinatorMenuHandler)menuHandler
{
    self.menuHandler = menuHandler;
}

- (void)startUpdatingAdminProgressMessages:(SHCoordinatorProgressHandler)progressHandler
{
    self.progressHandler = progressHandler;
}

- (void)startUpdatingAdminFeedbackMessages:(SHCoordinatorFeedbackHandler)feedbackHandler
{
    self.feedbackHandler = feedbackHandler;
}

@end
