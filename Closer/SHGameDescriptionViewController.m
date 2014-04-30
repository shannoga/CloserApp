//
//  SHGameDescriptionViewController.m
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGameDescriptionViewController.h"
#import "SHGameMenuViewController.h"
#import "SHGamesController.h"
@interface SHGameDescriptionViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *gameImage;
@property (nonatomic, weak) IBOutlet UILabel *gameTitle;
@property (nonatomic, weak) SHGameMenuViewController *currentMenuController;

@property (nonatomic) BOOL  isPresentingGameMenuController;

- (IBAction)gameTapped:(id)sender;

@end

@implementation SHGameDescriptionViewController

- (void)awakeFromNib
{
    self.currentMenuController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.borderColor = [UIColor orangeColor].CGColor;
    self.view.layer.borderWidth = 2;
    self.gameImage.image = [UIImage imageNamed:self.imageFile];
    self.gameImage.userInteractionEnabled = YES;
    self.gameTitle.text = self.titleText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adminSelectedMainGame
{
    DDLogInfo(@"admin selected game - %@",self.titleText);
    [self performSegueWithIdentifier:@"gameMenuSegue" sender:self];
}

- (IBAction)gameTapped:(id)sender
{
    DDLogInfo(@"user selected game - %@",self.titleText);
    [self.controllerContext.menuController adminDidSelectMainGameAtIndex:self.mainGame];
    [self performSegueWithIdentifier:@"gameMenuSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gameMenuSegue"]) {
        SHGameMenuViewController *menuController =(SHGameMenuViewController*)segue.destinationViewController;
        menuController.titleText = self.imageFile;
        menuController.mainGame = self.pageIndex;
        menuController.controllerContext = self.controllerContext;
        self.isPresentingGameMenuController = YES;
        self.currentMenuController = menuController;
    }
}

- (void)adminDidGoBackToMainMenu
{
    if(self.isPresentingGameMenuController)
    {
        [self.navigationController popViewControllerAnimated:YES];
        self.isPresentingGameMenuController = NO;
        [self.controllerContext.menuController adminDidGoBackToMainMenu];

    }
}

- (void)adminDidSelectSubGameIndex:(NSInteger)subGameIndex
{
    [self.currentMenuController adminDidSelectSubGameAtIndex:subGameIndex];
}

@end
