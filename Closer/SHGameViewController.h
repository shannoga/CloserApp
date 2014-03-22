//
//  SHGameViewController.h
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHGamesDataSource.h"
#import "SHBaseViewController.h"


@interface SHGameViewController : SHBaseViewController
@property (nonatomic,weak) IBOutlet UIButton *closeGameButton;
@property (nonatomic,weak) IBOutlet UIButton *nextButton;
@property (nonatomic,weak) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) SHGamesDataSource *gameDataSource;
@property (nonatomic) NSInteger questionIndex;
@property (nonatomic, weak) IBOutlet UILabel *instructionsLabel;

- (void)gotoStepAtIndex:(NSInteger)index;
- (IBAction)closeGame:(UIButton*)sender;
- (IBAction)getBackToPrevStep:(UIButton*)sender;
- (IBAction)gotoNextStep:(UIButton*)sender;

@end
