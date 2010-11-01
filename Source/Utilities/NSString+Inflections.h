//
//  NSString+Inflections.h
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Inflections)

/**
 * Returns a copy of the string with the first letter decapitalized.
 */
- (NSString *)stringByDecapitalizingFirstLetter;

/**
 * Returns a pluralized string.
 */
- (NSString *)pluralizedString;

/**
 * Returns a camelized string to a underscored string.
 */
- (NSString *)underscoredString;

@end
