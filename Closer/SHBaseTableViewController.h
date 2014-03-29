//
//  SHBaseTableViewController.h
//  Closer
//
//  Created by shani hajbi on 3/28/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHControllerContext.h"
#import "SHBaseViewController.h"
@interface SHBaseTableViewController : UITableViewController
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic, strong) SHControllerContext *controllerContext;

- (void)showHud;
- (void)hideHud;
@end
