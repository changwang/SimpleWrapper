//
//  SWBase.m
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWBase.h"
#import "NSObject+iPhone.h"
#import "NSString+Inflections.h"

@interface SWBase ()
- (NSString *)prepareKeyStrings:(NSArray *)keys;
- (NSString *)prepareSqlColumns:(NSArray *)columns;
- (NSDictionary *)prepareKeysAndValues:(NSArray *)columns;
- (void)saveOrUpdate:(BOOL)new;
@end

static id<SWConnection> defaultConnection = nil;

@implementation SWBase

@synthesize connection;
@synthesize lastID;
@synthesize isNew;

#pragma mark -
#pragma mark Initialize Methods

- (id)initWithPk:(NSUInteger)pk {
  return [self initWithConnection:[SWBase defaultConnection] pk:pk];
}

- (id)initWithConnection:(id<SWConnection>)aConnection pk:(NSUInteger)pk; {
  if (![super init]) {
	return nil;
  }
  self.connection = aConnection;
  self.lastID = pk;
  self.isNew = YES;
  [[self class] setDefaultConnection:connection];
  return self;
}

#pragma mark -
#pragma mark Record Operations

+ (id)createWithAttributes:(NSDictionary *)attrs connection:(id<SWConnection>)connection {
  NSString *creationSQL = [NSString stringWithFormat:@"INSERT INTO %@(id) VALUES(NULL)", [self tableName]];
  return creationSQL;
}

- (void)save {
  [self saveOrUpdate:isNew];
  self.isNew = NO;
}

- (BOOL)destory {
  @try {
	[self.connection executeSQL:[NSString stringWithFormat:@"DELETE FROM %@ WHERE id = :id", [[self class] className]] 
								 substitutions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.lastID] forKey:@"id"]];
	self.isNew = YES;
	[self autorelease];
	return YES;
  }
  @catch (NSException * e) {
	// TODO
  }
  return NO;
}

+ (BOOL)empty {
  NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", 
				   [[self class] tableName]];
  [defaultConnection executeSQL:sql substitutions:nil];
  return NO;
}

+ (NSUInteger)count {
  NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", 
				   [[self class] tableName]];
  NSArray *result = [defaultConnection executeSQL:sql substitutions:nil];
  return [result count];
}

#pragma mark -
#pragma mark Cache Methods

- (NSArray *)columns {
  if (!tableCache) {
	tableCache = [[self.connection columnsForTable:[[self class] tableName]] retain];
  }
  return tableCache;
}

- (NSArray *)columnsWithoutPrimaryKey {
  NSMutableArray *columns = [NSMutableArray arrayWithArray:[self columns]];
  [columns removeObjectAtIndex:0];
  return columns;
}

#pragma mark -
#pragma mark Private Methods

- (NSString *)prepareKeyStrings:(NSArray *)keys {
  NSMutableString *sqlKey = [NSMutableString string];
  for (int i = 0; i < [keys count]; i++) {
	(i == ([keys count] - 1)) ? [sqlKey appendFormat:@":%@ ", [keys objectAtIndex:i]] :
	  [sqlKey appendFormat:@":%@, ", [keys objectAtIndex:i]];
  }
  return sqlKey;
}

- (NSString *)prepareSqlColumns:(NSArray *)columns {
  NSMutableString *sqlColumns = [NSMutableString string];
  for (int i = 0; i < [columns count]; i++) {
	(i == ([columns count] - 1)) ? [sqlColumns appendFormat:@"%@ ", [columns objectAtIndex:i]] :
	  [sqlColumns appendFormat:@"%@, ", [columns objectAtIndex:i]];
  }
  return sqlColumns;
}

- (NSDictionary *)prepareKeysAndValues:(NSArray *)columns {
  NSMutableDictionary *keysAndValues = [NSMutableDictionary dictionary];
  for (NSString *key in columns) {
	[keysAndValues setObject:[self valueForKey:key] forKey:key];
  }
  return keysAndValues;
}

- (void)saveOrUpdate:(BOOL)new {
  NSArray *columnsWithoutPrimaryKey = [self columnsWithoutPrimaryKey];
  NSString *sql = nil;
  if (new) {
	sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
		   [[self class] tableName], 
		   [self prepareSqlColumns:columnsWithoutPrimaryKey],
		   [self prepareKeyStrings:columnsWithoutPrimaryKey]];
  } else {
	sql = [NSString stringWithFormat:@"UPDATE %@ (%@) SET (%@) WHERE id = %i",
		   [[self class] tableName],
		   [self prepareSqlColumns:columnsWithoutPrimaryKey],
		   [self prepareKeyStrings:columnsWithoutPrimaryKey],
		   self.lastID];
  }

  @try {
	[self.connection executeSQL:sql 
				  substitutions:[self prepareKeysAndValues:columnsWithoutPrimaryKey]];
  } @catch (NSException *e) {
	// TODO
  }
  if (new) {
	self.lastID = [self.connection lastInsertID];
  }
}

#pragma mark -
#pragma mark Model Configuration Methods

+ (void)setDefaultConnection:(id<SWConnection>)aConnection {
  [aConnection retain];
  [defaultConnection release];
  defaultConnection = aConnection;
}

+ (id<SWConnection>)defaultConnection {
  return defaultConnection;
}

+ (NSString *)tableName {
  NSMutableString *ret = [[[self className] mutableCopy] autorelease];
  ret = (NSMutableString *)[[ret lowercaseString] pluralizedString];
  return ret;
}

#pragma mark -
#pragma mark Memeory Management

- (void)dealloc {
  [tableCache release];
  [connection release];
  [super dealloc];
}

@end
