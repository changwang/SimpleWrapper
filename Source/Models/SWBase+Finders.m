//
//  SWBase+Finders.m
//  SimpleWrapper
//
//  Created by changwang on 10/31/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import "SWBase+Finders.h"


@implementation SWBase (Finders)

+ (NSArray *)find:(SWFindSpecification)spec {
  return [self find:spec andConnection:[self defaultConnection]];
}

+ (NSArray *)find:(SWFindSpecification)spec andConnection:(id<SWConnection>) aConnection {
  return [self find:spec select:@"id" filter:nil join:nil order:nil limit:0
		 connection:aConnection];
}

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql {
  return [self find:spec select:selectSql connection:[self defaultConnection]];
}

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql
	   connection:(id<SWConnection>)aConnection {
  return [self find:spec select:selectSql filter:nil join:nil order:nil limit:0
		 connection:aConnection];
}

+ (NSArray *)find:(SWFindSpecification)spec filter:(NSString *)whereSql
			 join:(NSString *)joinSql order:(NSString *)orderSql
			limit:(NSUInteger)limit {
  return [self find:spec select:@"id" filter:whereSql join:joinSql order:orderSql
			  limit:limit connection:[self defaultConnection]];
}

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql
		   filter:(NSString *)whereSql join:(NSString *)joinSql
			order:(NSString *)orderSql limit:(NSUInteger)limit {
  return [self find:spec select:selectSql filter:whereSql join:joinSql
			  order:orderSql limit:limit connection:[self defaultConnection]];
}

+ (NSArray *)find:(SWFindSpecification)spec filter:(NSString *)whereSql
			 join:(NSString *)joinSql order:(NSString *)orderSql
			limit:(NSUInteger)limit connection:(id<SWConnection>)aConnection {
  return [self find:spec select:@"id" filter:whereSql join:joinSql
			  order:orderSql limit:limit connection:aConnection];
}

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql
		   filter:(NSString *)whereSql join:(NSString *)joinSql
			order:(NSString *)orderSql limit:(NSUInteger)limit
	   connection:(id<SWConnection>)aConnection {
  NSArray *ids = [self findIds:spec select:selectSql filter:whereSql
						  join:joinSql order:orderSql limit:limit
					connection:aConnection];
  NSMutableArray *models = [NSMutableArray array];
  for (NSDictionary *match in ids) {
	NSUInteger pk = [[match objectForKey:@"id"] unsignedIntValue];
	[models addObject:[[[self alloc] initWithConnection:aConnection pk:pk] autorelease]];
  }
  return models;
}

+ (NSArray *)findIds:(SWFindSpecification)spec filter:(NSString *)whereSql 
				join:(NSString *)joinSql order:(NSString *)orderSql 
			   limit:(NSUInteger)limit connection:(id <SWConnection>)aConnection {
  return [self findIds:spec select:@"id" filter:whereSql join:joinSql
				 order:orderSql limit:limit connection:aConnection];
}

+ (NSArray *)findIds:(SWFindSpecification)spec select:(NSString *)selectSql
			  filter:(NSString *)whereSql join:(NSString *)joinSql
			   order:(NSString *)orderSql limit:(NSUInteger)limit
		  connection:(id<SWConnection>)aConnection {
  NSMutableString *sql;
  if ([selectSql isEqualToString:@"id"]) {
	sql = [NSMutableString stringWithFormat:@"SELECT id from %@", [self tableName]];
  } else {
	sql = [NSMutableString stringWithFormat:@"SELECT id, %@ FROM %@", selectSql, [self tableName]];
  }
  if (joinSql) {
	[sql appendFormat:@" %@", joinSql];
  }
  
  switch (spec) {
	case SWFindFirst:
	  if (limit == 0) {
		[sql appendFormat:@" LIMIT 1"];
	  }
	  break;
	case SWFindAll:
	  break;

	default:
	  [sql appendFormat:@" WHERE id=:id"];
	  break;
  }
  if (spec == SWFindAll || spec == SWFindFirst) {
	if (whereSql != nil) {
	  [sql appendFormat:@" WHERE %@", whereSql];
	}
	if (orderSql != nil) {
	  [sql appendFormat:@" ORDER BY %@", orderSql];
	}
  } else {
	if (whereSql != nil) {
	  [sql appendFormat:@" AND %@", whereSql];
	}
	if (orderSql != nil) {
	  [sql appendFormat:@" ORDER %@", orderSql];
	}
  }
  if (limit > 0) {
	[sql appendFormat:@" LIMIT %d", limit];
  }
  return [aConnection executeSQL:sql
				   substitutions:[NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInteger:spec], @"id", nil]];
}

#pragma mark -
#pragma mark Convenient Methods

+ (NSArray *)findAll {
  return [self find:SWFindAll];
}

+ (id)first {
  return [self find:SWFindFirst];
}

+ (id)last {
  NSArray *ret = [self find:SWFindFirst filter:nil join:nil order:@"id DESC" limit:1];
  if (ret && [ret count] > 0) {
	return [ret objectAtIndex:0];
  }
  return nil;
}

@end
