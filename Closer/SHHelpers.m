//
//  SHHelpers.m
//  Closer
//
//  Created by shani hajbi on 2/11/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import "SHHelpers.h"

@implementation SHHelpers

BOOL is_iPhone5() {
#ifdef UI_USER_INTERFACE_IDIOM
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && screenSize.height > 480.0f);
#else
    return NO;
#endif
}

BOOL is_iPad() {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}


float screenWidth() {
#ifdef UI_USER_INTERFACE_IDIOM
    return is_iPad() ? 768. : 320.;
#else
    return 320.;
#endif
}

float screenHeight() {
#ifdef UI_USER_INTERFACE_IDIOM
    return is_iPad() ? 1024. : 480.;
#else
    return 480.;
#endif
}
@end
