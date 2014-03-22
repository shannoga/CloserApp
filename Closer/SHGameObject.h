//
//  SHGameObject.h
//  Closer
//
//  Created by shani hajbi on 2/25/14.
//  Copyright (c) 2014 shannoga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHGameObject : NSObject

- (id)initWithTitle:(NSString*)title  imageName:(NSString*)imageName instructionsString:(NSString*)instructionsString;

@property (nonatomic, copy) NSString *instructionsString;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;
@end
