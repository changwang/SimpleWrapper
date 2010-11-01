//
//  SWConnection.h
//  SimpleWrapper
//
//  Created by changwang on 10/24/10.
//  Copyright 2010 WMU. All rights reserved.
//

@protocol SWConnection <NSObject>

/**
 * Expect a dictionary with connection info, sqlite3 only needs path info,
 * MySQL and Postgresql should also provide username, password, host etc.
 */
+ (id)openConnectionWithInfo:(NSDictionary *)info error:(NSError **)err;

/**
 * Instance method.
 */
- (id)initConnectionWithInfo:(NSDictionary *)info error:(NSError **)err;

/**
 * Close the database connection.
 */
- (void)closeConnection;

- (NSArray *)executeSQL:(NSString *)query substitutions:(NSDictionary *)substitutions;

- (NSArray *)columnsForTable:(NSString *)tableName;

/**
 * Transaction concerns
 */
- (BOOL)beginTransaction;
- (BOOL)endTransaction;

- (NSUInteger)lastInsertID;

@end
