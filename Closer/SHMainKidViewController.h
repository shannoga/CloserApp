//
//  SHMainKidViewController.h
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHBaseViewController.h"
@protocol SHMainViewControllerDelegate <NSObject>
- (void)userDidExitGame;
@end

@interface SHMainKidViewController : SHBaseViewController
@property (nonatomic, weak) id <SHMainViewControllerDelegate> delegate;
@end
