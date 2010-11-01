//
//  NSString+iPhone.m
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "NSObject+iPhone.h"


@implementation NSObject (iPhone)

+ (NSString *)className {
  return NSStringFromClass(self);
}

- (NSString *)className {
  return [[self class] className];
}

@end
