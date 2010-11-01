//
//  SWSqlite3Connection.h
//  SimpleWrapper
//
//  Created by changwang on 10/24/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <SimpleWrapper/SWConnection.h>

#define SQLITEERRORDOMAIN			@"database.sqlite.error.filenotfound"
#define SQLITECLOSEEXCEPTION		@"database.sqlite.exception.close"
#define SQLITEQUERYEXCEPTION		@"database.sqlite.exception.query"
#define SQLITETYPEEXCEPTION			@"database.sqlite.exception.type"
#define SQLITEEXECUTIONEXCEPTION	@"database.sqlite.exception.execution"
#define SQLITETRANSACTIONEXCEPTION	@"database.sqlite.exception.transaction"

typedef enum {
  SWSqlite3DatabaseNotFoundError = 0
} SWSqlite3Error;

@interface SWSqlite3Connection : NSObject <SWConnection> {

  sqlite3 *db;
}

/**
 * Return a ready to use sqlite3 connection.
 * Expects a dictionary with a single key: "path" which is the path to the
 * Sqlite3 database file, sets 'err' and returns nil on error.
 */
+ (id)openConnectionWithInfo:(NSDictionary *)info error:(NSError **)err;

- (id)initConnectionWithInfo:(NSDictionary *)info error:(NSError **)err;

- (void)closeConnection;

/**
 * Executes the given SQL sring after binding (optional) the parameters in the query.
 * If there is no binding, pass nil to it.
 * Substitution is a key/value pair to indicate the value of a specific column.
 * Example usage:
 * [conn executeSQL:@"INSERT INTO FOO(id, name) VALUES(:id, :name)"
 *		  substitutions:[NSDictionary dictionaryWithObjectsAndKeys:
 *						  myId, @"id",
 *						  name, @"name", nil]];
 */
- (NSArray *)executeSQL:(NSString *)query substitutions:(NSDictionary *)substitutions;

/**
 * Returns a array of strings containing the column names for the given table.
 */
- (NSArray *)columnsForTable:(NSString *)tableName;

/**
 * returns the id of the row last inserted into
 */
- (NSUInteger)lastInsertID;

/**
 * I use this to test after closing the connection, whether the database handler
 * is set to NULL
 */
- (sqlite3 *)db;

/**
 * Begins a transaction.
 */
- (BOOL)beginTransaction;

/**
 * Ends a transaction.
 */
- (BOOL)endTransaction;

@end
