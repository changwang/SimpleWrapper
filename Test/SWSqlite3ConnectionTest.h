//
//  SWSqlite3ConnectionTest.h
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "GTMSenTestCase.h"

@class SWSqlite3Connection;

@interface SWSqlite3ConnectionTest : GTMTestCase {

  SWSqlite3Connection *connection;
}

- (void)testConnection;
- (void)testCloseConnection;
- (void)testQuery;
- (void)testColumnForTable;

@end
