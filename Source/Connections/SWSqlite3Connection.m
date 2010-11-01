//
//  SWSqlite3Connection.m
//  SimpleWrapper
//
//  Created by changwang on 10/24/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWSqlite3Connection.h"
#import "NSObject+iPhone.h"
#import <unistd.h>

@interface SWSqlite3Connection ()

- (sqlite3_stmt *)prepareQuerySQL:(NSString *)sql;
- (NSArray *)columnsForQuery:(sqlite3_stmt *)statement;
- (id)valueForColumn:(unsigned int)colIndex withStatement:(sqlite3_stmt *)statement;
- (NSString *)getSubType:(id)sub;
- (void)finalizeStatement:(sqlite3_stmt *)statement;

- (sqlite3 *)db;

@end

#pragma mark -

@implementation SWSqlite3Connection

#pragma mark -
#pragma mark Initializations

+ (id)openConnectionWithInfo:(NSDictionary *)info error:(NSError **)err {
  return [[[SWSqlite3Connection alloc] initConnectionWithInfo:info error:err] autorelease];
}

- (id)initConnectionWithInfo:(NSDictionary *)info error:(NSError **)err {
  NSString *path = [info objectForKey:@"path"] ? [info objectForKey:@"path"] : @"";
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
	*err = [NSError errorWithDomain:SQLITEERRORDOMAIN
							   code:SWSqlite3DatabaseNotFoundError
						   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									 NSLocalizedString(@"SQLite database not found", @""), NSLocalizedDescriptionKey,
									 path, NSFilePathErrorKey, nil]];
#ifdef DEBUG
	NSLog(@"SimpleWrapper -- %@", [*err localizedDescription]);
#endif

	return nil;
  }

  int sqliteErr = 0;
  sqliteErr = sqlite3_open([path UTF8String], &db);
  if (sqliteErr != SQLITE_OK) {
	const char *errStr = sqlite3_errmsg(db);
	*err = [NSError errorWithDomain:SQLITEERRORDOMAIN
							   code:SWSqlite3DatabaseNotFoundError
						   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSString stringWithUTF8String:errStr], NSLocalizedDescriptionKey,
									 path, NSFilePathErrorKey, nil]];
#ifdef DEBUG
	NSLog(@"SimpleWrapper -- %@", [*err localizedDescription]);
#endif

	return nil;
  }
  return self;
}

#pragma mark -
#pragma mark Resources Management

- (void)closeConnection {
  if (sqlite3_close(db) != SQLITE_OK) {
	[NSException raise:SQLITECLOSEEXCEPTION format:@"Failed to close database. Details: %@",
	 sqlite3_errmsg16(db)];
  }
  db = NULL;
}

#pragma mark -
#pragma mark SQL Execution

- (NSArray *)executeSQL:(NSString *)sql substitutions:(NSDictionary *)substitutions {
  /* sqlite3_stmt is used to compose SQL statement by underlying system */
  sqlite3_stmt *queryStatement;
  queryStatement = [self prepareQuerySQL:sql];
  NSArray *columnNames = [self columnsForQuery:queryStatement];
  for (int i = 1; i <= sqlite3_bind_parameter_count(queryStatement); ++i) {
	const char *keyCString = sqlite3_bind_parameter_name(queryStatement, i);
	if (!keyCString) {
	  continue;
	}
	NSString *key = [[NSString stringWithUTF8String:keyCString]
					 stringByReplacingOccurrencesOfString:@":" withString:@""];
	id sub = [substitutions objectForKey:key];
	if (!sub) {
	  continue;
	}
	NSString *type = [self getSubType:sub];
	
	if ([type isEqualToString:@"NSString"]) {
	  sqlite3_bind_text(queryStatement, i, [sub UTF8String], -1, SQLITE_TRANSIENT);
	} else if ([type isEqualToString:@"NSData"]) {
	  sqlite3_bind_blob(queryStatement, i, [sub bytes], [sub length], SQLITE_STATIC);
	} else if ([type isEqualToString:@"NSNumber"]) {
	  sqlite3_bind_double(queryStatement, i, [sub doubleValue]);
	} else if ([type isEqualToString:@"NSNull"]) {
	  sqlite3_bind_null(queryStatement, i);
	} else {
	  [NSException raise:SQLITETYPEEXCEPTION 
				  format:@"Couldn't recognize the given type of object: %@ of class: %@",
	   sub, [sub className]];
	}
  }
  
  NSMutableArray *rowArray = [NSMutableArray array];
  NSMutableDictionary *columns;
  int err = 0;
  while ((err = sqlite3_step(queryStatement)) != SQLITE_DONE) {
	if (err == SQLITE_BUSY) {
	  usleep(100);
	} else if (err == SQLITE_ERROR || err == SQLITE_MISUSE) {
	  [NSException raise:SQLITEEXECUTIONEXCEPTION 
				  format:@"Query: %@ Details: %@", sql,
	   [NSString stringWithUTF8String:sqlite3_errmsg16(db)]];
	  break;
	} else if (err == SQLITE_ROW) {
	  // Have another row prepared
	  columns = [NSMutableDictionary dictionary];
	  int i = 0;
	  for (NSString *columnName in columnNames) {
		[columns setObject:[self valueForColumn:i withStatement:queryStatement] forKey:columnName];
		++i;
	  }
	  [rowArray addObject:columns];
	}
  }
  
#ifdef DEBUG
  const char *preparedSQL = sqlite3_sql(queryStatement);
  NSLog(@"SimpleWrapper -- %@", [NSString stringWithUTF8String:preparedSQL]);
#endif
  
  [self finalizeStatement:queryStatement];
  
  return rowArray;
}

- (NSArray *)columnsForTable:(NSString *)tableName {
  sqlite3_stmt *stmt = [self prepareQuerySQL:[NSString stringWithFormat:@"SELECT * FROM %@", tableName]];
  NSArray *columns = [self columnsForQuery:stmt];
  [self finalizeStatement:stmt];
  return columns;
}

- (NSUInteger)lastInsertID {
  return (NSUInteger)sqlite3_last_insert_rowid(db);
}

#pragma mark -
#pragma mark Transaction Concerns

- (BOOL)beginTransaction {
  char *errMsg;
  int err = sqlite3_exec(db, "BEGIN TRANSACTION", NULL, NULL, &errMsg);
  if (err != SQLITE_OK) {
	[NSException raise:SQLITETRANSACTIONEXCEPTION 
				format:@"Couldn't start transaction. Details: %@", [NSString stringWithUTF8String:errMsg]];
	return NO;
  }
  return YES;
}

- (BOOL)endTransaction {
  char *errMsg;
  int err = sqlite3_exec(db, "END TRANSACTION", NULL, NULL, &errMsg);
  if (err != SQLITE_OK) {
	[NSException raise:SQLITETRANSACTIONEXCEPTION 
				format:@"Couldn't end transaction. Details: %@", [NSString stringWithUTF8String:errMsg]];
	return NO;
  }
  return YES;
}

#pragma mark -
#pragma mark Private Methods

- (sqlite3_stmt *)prepareQuerySQL:(NSString *)sql {
  sqlite3_stmt *statement;
  const char *tail;
  int err = sqlite3_prepare_v2(db, [sql UTF8String],
							   [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
							   &statement, &tail);
  if (err != SQLITE_OK || statement == NULL) {
	[NSException raise:SQLITEQUERYEXCEPTION format:@"Couldn't compile the query: %@. Details: %@",
	 sql, sqlite3_errmsg16(db)];
	return nil;
  }
  return statement;
}

- (NSArray *)columnsForQuery:(sqlite3_stmt *)statement {
  int columnCount = sqlite3_column_count(statement);
  if (columnCount <= 0) {
	return nil;
  }
  NSMutableArray *columnNames = [NSMutableArray array];
  for (int i = 0; i < columnCount; ++i) {
	const char *name;
	name = sqlite3_column_name(statement, i);
	[columnNames addObject:[NSString stringWithUTF8String:name]];
  }
  return columnNames;
}

- (NSString *)getSubType:(id)sub {
  if ([sub isMemberOfClass:[NSString class]] 
	  || [[sub className] isEqualToString:@"NSCFString"]) {
	return @"NSString";
  }
  if ([sub isMemberOfClass:[NSData class]] 
	  || [[sub className] isEqualToString:@"NSConcreteData"]
	  || [[sub className] isEqualToString:@"NSConcreteMutableData"]
	  || [[sub className] isEqualToString:@"NSCFData"]) {
	return @"NSData";
  }
  if ([[sub className] isEqualToString:@"NSCFNumber"]) {
	return @"NSNumber";
  }
  if ([sub isMemberOfClass:[NSNull class]]) {
	return @"NSNull";
  }
  return nil;
}

- (id)valueForColumn:(unsigned int)colIndex withStatement:(sqlite3_stmt *)statement {
  int columnType = sqlite3_column_type(statement, colIndex);
  switch (columnType) {
	case SQLITE_INTEGER:
	  return [NSNumber numberWithInt:sqlite3_column_int(statement, columnType)];
	  break;
	case SQLITE_FLOAT:
	  return [NSNumber numberWithFloat:sqlite3_column_double(statement, colIndex)];
	  break;
	case SQLITE_BLOB:
	  return [NSData dataWithBytes:sqlite3_column_blob(statement, colIndex)
							length:sqlite3_column_bytes(statement, colIndex)];
	  break;
	case SQLITE_NULL:
	  return [NSNull null];
	  break;
	case SQLITE_TEXT:
	  return [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, colIndex)];
	  break;
	default:
	  break;
  }
  return nil;
}

- (void)finalizeStatement:(sqlite3_stmt *)statement {
  sqlite3_finalize(statement);
}

#pragma mark -
#pragma mark Test Used Only

- (sqlite3 *)db {
  return db;
}

@end
