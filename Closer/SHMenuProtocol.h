//
//  SHMenuProtocol.h
//  Closer
//
//  Created by shani hajbi on 4/5/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHMenuProtocol <NSObject>
- (void)adminDidNavigateToPageAtIndex:(NSInteger)index;
- (void)adminDidSelectPageForMainGame:(NSInteger)index;
- (void)adminDidGoBackToMainMenu;
- (void)adminDidSelectSubGameAtIndex:(NSInteger)subGameIndex;
@end
