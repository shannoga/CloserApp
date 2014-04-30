//
//  SHGroupsController.h
//  Closer
//
//  Created by shani hajbi on 3/24/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHControllerContext.h"
#import "SHPubNubController.h"

@protocol SHUserProfileControllerDelegate
- (void)activeUsersDidUpdatePresence;
- (void)userDidCall:(NSString *)userId answerHandler:(void (^)(SHCallResult callResult))answerHandler;
@end

@interface SHUserProfileController : NSObject
@property (nonatomic, strong) NSMutableArray *activeUsers;
@property (nonatomic, strong) PFObject *activeGroup;
@property (nonatomic, weak) id <SHUserProfileControllerDelegate> delegate;
@property (nonatomic, strong) SHControllerContext *controllerContext;

- (void)activeGroupWithBlock:(void (^)(PFObject *group))completion;
- (void)updateUserGroup:(NSString*)groupName;
- (void)getActiveGroupUsersWithBlock:(void (^)(NSArray *users,NSError *error))completion;
- (void)updateGroupImage:(UIImage*)image;
- (void)prepareForLogout;
@end
