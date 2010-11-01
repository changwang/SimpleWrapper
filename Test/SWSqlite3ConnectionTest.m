//
//  SWSqlite3ConnectionTest.m
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWSqlite3ConnectionTest.h"
#import "SWSqlite3Connection.h"
#import "GTMSenTestCase+Fixtures.h"

@implementation SWSqlite3ConnectionTest

- (void)setUp {
  [connection release];
  connection = [[super setUpSQLite3Fixtures] retain];
}

- (void)tearDown {
  if ([connection db]) {
	[connection closeConnection];
  }
}

- (void)testConnection {
  STAssertNotNil(connection, @"Connection should not be nil");
}

- (void)testCloseConnection {
  [connection closeConnection];
  STAssertNULL([connection db], @"Connection should be nil");
}

- (void)testQuery {
  NSString *query = @"SELECT * FROM foo";
  NSArray *result = [connection executeSQL:query substitutions:nil];
  STAssertTrue([result count] == 2, @"foo should have 2 rows");
}

- (void)testColumnForTable {
  NSArray *result = [connection columnsForTable:@"foo"];
  STAssertTrue([result count] == 4, @"foo should have 4 columns");
  STAssertEqualStrings([result objectAtIndex:0], @"id", @"first column should be 'id'");
  STAssertEqualStrings([result objectAtIndex:1], @"bar", @"second column should be 'bar'");
  STAssertEqualStrings([result objectAtIndex:2], @"baz", @"third column should be 'baz'");
  STAssertEqualStrings([result objectAtIndex:3], @"integer", @"fourth column should be 'integer'");
}

@end
