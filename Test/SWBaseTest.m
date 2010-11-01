//
//  SWBaseTest.m
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWBaseTest.h"
#import "SWBase.h"
#import "GTMSenTestCase+Fixtures.h"

@implementation SWBaseTest

- (void)setUp {
  connection = [[super setUpSQLite3Fixtures] retain];
  base = [[SWBase alloc] initWithConnection:connection];
}

- (void)testTableName {
  NSString *name = [SWBase tableName];
  STAssertEqualStrings(name, @"swbases", @"table name should be 'base'");
}

- (void)testTableCache {
  NSArray *tableColumns = [base columns];
  STAssertTrue([tableColumns count] > 0, @"table should have at least 1 column");
  STAssertTrue([tableColumns count] == 3, @"table swbases has 3 columns");
  STAssertEqualStrings([tableColumns objectAtIndex:0], @"id", @"first column is 'id'");
  STAssertEqualStrings([tableColumns objectAtIndex:1], @"name", @"first column is 'name'");
  STAssertEqualStrings([tableColumns objectAtIndex:2], @"password", @"first column is 'password'");
}

- (void)testTableCacheWithoutPrimaryKey {
  NSArray *tableColumnWithoutPK = [base columnsWithoutPrimaryKey];
  STAssertTrue([tableColumnWithoutPK count] > 0, @"table should have at least 1 column");
  STAssertTrue([tableColumnWithoutPK count] == 2, @"table swbases has 2 columns");
  STAssertEqualStrings([tableColumnWithoutPK objectAtIndex:0], @"name", @"first column is 'name'");
  STAssertEqualStrings([tableColumnWithoutPK objectAtIndex:1], @"password", @"first column is 'password'");
}

- (void)testSqlKeys {
  NSArray *keys = [NSArray arrayWithObjects:@"name", @"password", nil];
  STAssertEqualStrings([base prepareKeyStrings:keys], @":name, :password ", @"generated keys should be this");
}

- (void)testPrepareSqlColumns {
  NSArray *columns = [NSArray arrayWithObjects:@"name", @"password", nil];
  STAssertEqualStrings([base prepareSqlColumns:columns], @"name, password ", @"generated columns");
}

- (void)tearDown {
  [connection closeConnection];
}

@end
