//
//  SWModel.h
//  SimpleWrapper
//
//  Created by changwang on 10/30/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWBase.h"

@interface Grocery : SWBase {

  NSString *name;
  NSNumber *number;
}

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSNumber *number;

@end
