//
//  GTMSenTestCase+Fixtures.m
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "GTMSenTestCase+Fixtures.h"


@implementation GTMTestCase (Fixtures)

- (SWSqlite3Connection *)setUpSQLite3Fixtures {
  NSError *err = nil;
  NSMutableString *path = [NSMutableString stringWithUTF8String:__FILE__];
  [path replaceOccurrencesOfString:[path lastPathComponent]
						withString:@"" options:0
							 range:NSMakeRange(0, [path length])];
  [path appendString:@"simpleDatabase.db"];
  NSString *fixturePath = [path stringByReplacingOccurrencesOfString:[path lastPathComponent]
														  withString:@"sqlite_fixtures.sql"
															 options:0
															   range:NSMakeRange(0, [path length])];
  NSString *fixtures = [NSString stringWithContentsOfFile:fixturePath
												 encoding:NSUTF8StringEncoding
													error:nil];
  SWSqlite3Connection *connection = [SWSqlite3Connection openConnectionWithInfo:[NSDictionary dictionaryWithObject:path forKey:@"path"]
																		  error:&err];
  for (NSString *query in [fixtures componentsSeparatedByString:@"\n"]) {
	@try {
	  //[connection executeSQL:query substitutions:nil];
	}
	@catch (NSException * e) {
	  NSLog(@"FIXTUREFAIL!(%@): %@", query, e);
	}
  }
  return connection;
}

@end
