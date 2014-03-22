//
//  SHGameObjectView.h
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHGameObjectView : UIView
@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *title;

- (void)stopParticleEffect;
- (void)startParticleEffect;
@end
