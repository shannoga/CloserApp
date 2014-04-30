//
//  SHKidMenuViewController.m
//  Closer
//
//  Created by shani hajbi on 4/5/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHKidMenuViewController.h"

@interface SHKidMenuViewController ()
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) IBOutlet UILabel *label;
@end

@implementation SHKidMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //wait for 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -SHMenuProtocol

- (void)adminDidNavigateToPageAtIndex:(NSInteger)index
{
    self.imageView.image = [UIImage imageNamed:kMainGamesImages[index]];
}

- (void)adminDidSelectPageForMainGame:(NSInteger)index
{
    

}

- (void)adminDidGoBackToMainMenu
{
    
}

- (void)adminDidSelectSubGameAtIndex:(NSInteger)subGameIndex
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
