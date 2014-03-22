//
//  SHGameObject.m
//  Closer
//
//  Created by shani hajbi on 2/25/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHGameObject.h"

@implementation SHGameObject

- (id)initWithTitle:(NSString*)title  imageName:(NSString*)imageName instructionsString:(NSString*)instructionsString
{
    self = [super init];
    if (self) {
       // NSAssert(imageName && [UIImage imageNamed:imageName], @"Missing image : %@",imageName);
      //  NSAssert(instructionsString, @"Game Object must have instructions : %@",imageName);

        self.imageName = imageName;
        self.title = title;
        self.instructionsString = instructionsString;
    }
    return self;
}


@end
