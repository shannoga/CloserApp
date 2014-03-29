//
//  SHBaseTableViewController.m
//  Closer
//
//  Created by shani hajbi on 3/28/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHBaseTableViewController.h"
#import <MBProgressHUD.h>

@interface SHBaseTableViewController ()
@end

@implementation SHBaseTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)showHud
{
    [self.hud show:YES];
}

- (void)hideHud
{
    [self.hud hide:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
