//
//  SWModelTest.h
//  SimpleWrapper
//
//  Created by changwang on 10/30/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "SWBase.h"
#import "SWSqlite3Connection.h"
#import "Grocery.h"

@interface SWModelTest : GTMTestCase {

  Grocery *grocery;
  SWSqlite3Connection *connection;
}

- (void)testCount;
- (void)testSave;

@end
