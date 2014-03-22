//
//  SHFParticleView.h
//  


#import <UIKit/UIKit.h>

@interface SHFParticleView : UIView
@property (nonatomic) BOOL isEmitting;
-(void)setEmitterPositionFromTouch: (UITouch*)t;
-(void)setIsEmitting:(BOOL)isEmitting;
@end
