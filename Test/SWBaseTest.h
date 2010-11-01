//
//  SWBaseTest.h
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "SWBase.h"
#import "SWSqlite3Connection.h"

@interface SWBaseTest : GTMTestCase {
  SWBase *base;
  SWSqlite3Connection *connection;
}

- (void)testTableName;
- (void)testPrepareSqlColumns;
@end
