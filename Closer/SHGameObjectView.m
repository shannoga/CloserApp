//
//  SHGameObjectView.m
//  Closer
//
//  Created by shani hajbi on 2/12/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGameObjectView.h"
#import "SHFParticleView.h"
@interface SHGameObjectView ()
@property (nonatomic,weak) IBOutlet SHFParticleView *particleView;
@property (nonatomic,weak) IBOutlet UIImageView *image;
@property (nonatomic,weak) IBOutlet UILabel *label;


@end

@implementation SHGameObjectView

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_particleView setEmitterPositionFromTouch: [touches anyObject]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_particleView setEmitterPositionFromTouch: [touches anyObject]];
    [_particleView setIsEmitting:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   // [_particleView setIsEmitting:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [_particleView setIsEmitting:NO];
}

- (void)stopParticleEffect
{
    if (_particleView.isEmitting) {
        [_particleView setIsEmitting:NO];
    }
}

- (void)startParticleEffect
{
    
}

- (void)setImageName:(NSString *)imageName
{
    if (imageName == _imageName) {
        return;
    }
    _imageName = imageName;
    [self.image setImage:[UIImage imageNamed:_imageName]];
}

- (void)setTitle:(NSString *)title
{
    if (title  == _title) {
        return;
    }
    _title = title;
    self.label.text = _title;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
