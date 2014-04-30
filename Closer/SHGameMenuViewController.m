//
//  SHGameMenuViewController.m
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGameMenuViewController.h"
#import "SHSubGameConnetionViewCell.h"
#import "SHSingleObjectGameViewController.h"
#import "SHGamesProvider.h"
#import "SHGamesController.h"

@interface SHGameMenuViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) NSArray *subGames;
@end

@implementation SHGameMenuViewController

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
    self.title = self.titleText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [SHGamesProvider numberOfSubGamesForGame:self.mainGame];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHSubGameConnetionViewCell *cell = (SHSubGameConnetionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"subGameCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    cell.subGameImage.image = [UIImage imageNamed:[SHGamesProvider titleForSubGame:self.mainGame atIndex:indexPath.row localized:NO]];
    cell.subGameTitle.text = [SHGamesProvider titleForSubGame:self.mainGame atIndex:indexPath.row localized:YES];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SingleObjectGameController"]) {
        SHSingleObjectGameViewController *singleGameController = (SHSingleObjectGameViewController*)segue.destinationViewController;
        self.controllerContext.gamesController.gameViewController = singleGameController;
        singleGameController.controllerContext = self.controllerContext;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.controllerContext.gamesController startNewGame:self.mainGame completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogInfo(@"user selected sub game - %@",[SHGamesProvider titleForSubGame:self.mainGame atIndex:indexPath.row localized:YES]);
            [self.controllerContext.menuController adminDidSelectSubGameAtIndex:indexPath.row];
            NSString *segueId = [SHGamesProvider segueNameForMainGame:self.mainGame atIndex:indexPath.row];
            [self performSegueWithIdentifier:segueId sender:self];
        });
    }];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark – UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35;
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}


#pragma mark admin actions
- (void)adminDidSelectSubGameAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    DDLogInfo(@"admin selected sub game - %@",[SHGamesProvider titleForSubGame:self.mainGame atIndex:indexPath.row localized:YES]);
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    NSString *segueId = [SHGamesProvider segueNameForMainGame:self.mainGame atIndex:indexPath.row];
    [self performSegueWithIdentifier:segueId sender:self];
}


@end
