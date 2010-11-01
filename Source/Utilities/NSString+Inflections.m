//
//  NSString+Inflections.m
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "NSString+Inflections.h"


@implementation NSString (Inflections)

- (NSString *)stringByDecapitalizingFirstLetter {
  NSString *lowercase = [self lowercaseString];
  if ([self length] > 1) {
	return [NSString stringWithFormat:@"%@%@", [lowercase substringWithRange:NSMakeRange(0, 1)],
			[self substringWithRange:NSMakeRange(1, [self length] - 1)]];
  }
  return lowercase;
}

- (NSString *)underscoredString {
  return self;
}

- (NSString *)pluralizedString {
  NSMutableString *ret = [NSMutableString stringWithString:self];
  // Right now I only add s to the end of the string
  [ret appendString:@"s"];
  return ret;
}

@end
