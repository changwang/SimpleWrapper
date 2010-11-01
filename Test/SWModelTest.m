//
//  SWModelTest.m
//  SimpleWrapper
//
//  Created by changwang on 10/30/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWModelTest.h"
#import "GTMSenTestCase+Fixtures.h"

@implementation SWModelTest

- (void)setUp {
  connection = [[super setUpSQLite3Fixtures] retain];
  grocery = [[Grocery alloc] initWithConnection:connection];
}

- (void)testCount {
  NSUInteger rows = [Grocery count];
  STAssertTrue(0 == rows, @"There is no row right now");
}

- (void)testSave {
  NSUInteger rows = [Grocery count];
  grocery.name = @"apple";
  grocery.number = [NSNumber numberWithInt:10];
  [grocery save];
  NSLog(@"id is %i", grocery.lastID);
  STAssertTrue(1 == (rows + 1), @"There should be one record in the table.");
}

- (void)tearDown {
  [Grocery empty];
  [grocery release];
  [connection closeConnection];
}

@end
