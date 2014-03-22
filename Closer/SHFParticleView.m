//
//  SHFParticleView.m
// 

#import "SHFParticleView.h"
#import <QuartzCore/QuartzCore.h>



#define kbirthRate          @"birthRate"
#define kbirthRateMax       @"birthrateMax"
#define klifetime           @"lifetime"
#define klifetimeRange      @"lifetimeRange"
#define kpositionRangeX     @"positionRangeX"
#define kpositionRangeY     @"positionRangeY"
#define kangleRange         @"angleRange"
#define kspeed              @"speed"
#define kspeedRange         @"speedRange"
#define kaccelerationX      @"accelerationX"
#define kaccelerationY      @"accelerationY"
#define kstartAlpha         @"startAlpha"
#define kalphaRange         @"alphaRange"
#define kalphaSpeed         @"alphaSpeed"
#define kscale              @"scale"
#define kscaleRange         @"scaleRange"
#define kscaleSpeed         @"scaleSpeed"
#define kstartRotation      @"startRotation"
#define krotationRange      @"rotationRange"
#define krotationSpeed      @"rotationSpeed"
#define kcolorBlendFactor   @"colorBlendFactor"
#define kcolorBlendRange    @"colorBlendRange"
#define kcoloeBlendSpeed    @"coloeBlendSpeed"
#define kcolor              @"color"
#define kblendMode          @"blendMode"
#define kimageFile      @"imageFile"


@implementation SHFParticleView
{
    CAEmitterLayer* fireEmitter; //1
   CGFloat birthRate;
}

-(void)awakeFromNib
{
    NSString *myPlistFilePath = [[NSBundle mainBundle] pathForResource: @"starParticle" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: myPlistFilePath];
    fireEmitter = (CAEmitterLayer*)self.layer; //2
    fireEmitter.emitterPosition = CGPointMake(50, 50);
    fireEmitter.emitterSize = CGSizeMake(90, 90);
    
    CAEmitterCell* fire = [CAEmitterCell emitterCell];
    
    //kbirthRateMax / positionRangeXY / alpha
    birthRate =             [dict[kbirthRate]  floatValue];
    fire.birthRate =        0;
    fire.lifetime =         [dict[klifetime]   floatValue];
    fire.lifetimeRange =    [dict[klifetime]   floatValue];
    fire.speed =            [dict[kspeed]      floatValue];
    fire.scale =            [dict[kscale]      floatValue];
    fire.scaleRange =       [dict[kscaleRange] floatValue];
    fire.scaleSpeed =       [dict[kscaleSpeed] floatValue];
    fire.alphaRange =       [dict[kalphaRange] floatValue];
    fire.alphaSpeed =       [dict[kalphaSpeed] floatValue];
    fire.xAcceleration =    [dict[kaccelerationX] floatValue];
    fire.yAcceleration =    [dict[kaccelerationY] floatValue];
    fire.velocity =         200.0;
    fire.velocityRange =    50.0;
    fire.emissionLatitude = M_PI/2;
    fire.emissionLongitude = M_PI/2;
    fire.emissionRange = 100.0;
    fire.color = [UIColor whiteColor].CGColor;
    [fire setName:@"star"];
    fire.contents = (id)[[UIImage imageNamed:dict[kimageFile]] CGImage];
    
    
    fireEmitter.renderMode = kCAEmitterLayerAdditive;
    fireEmitter.emitterMode = kCAEmitterLayerPoint;
    fireEmitter.emitterShape = kCAEmitterLayerCircle;
    //add the cell to the layer and we're done
    fireEmitter.emitterCells = [NSArray arrayWithObject:fire];
    
}

+ (Class) layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

-(void)setEmitterPositionFromTouch: (UITouch*)t
{
    //change the emitter's position
    fireEmitter.emitterPosition = [t locationInView:self];
}

-(void)setIsEmitting:(BOOL)isEmitting
{
    //turn on/off the emitting of particles
    _isEmitting = isEmitting;
    [fireEmitter setValue:[NSNumber numberWithInt:isEmitting?birthRate:0] forKeyPath:@"emitterCells.star.birthRate"];
}


@end
