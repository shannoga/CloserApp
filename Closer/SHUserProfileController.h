//
//  SHGroupsController.h
//  Closer
//
//  Created by shani hajbi on 3/24/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHUserProfileController : NSObject
- (void)activeGroupWithBlock:(void (^)(PFObject *group))completion;
- (void)updateUserGroup:(NSString*)groupName;
- (void)getActiveGroupUsersWithBlock:(void (^)(NSArray *users,NSError *error))completion;
- (void)updateGroupImage:(UIImage*)image;
@end
