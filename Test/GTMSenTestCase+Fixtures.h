//
//  GTMSenTestCase+Fixtures.h
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "SWSqlite3Connection.h"

@interface GTMTestCase (Fixtures)

- (SWSqlite3Connection *)setUpSQLite3Fixtures;

@end
