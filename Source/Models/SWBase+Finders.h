//
//  SWBase+Finders.h
//  SimpleWrapper
//
//  Created by changwang on 10/31/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import <SimpleWrapper/SWBase.h>

@interface SWBase (Finders)

+ (NSArray *)findAll;

+ (id)first;
+ (id)last;

+ (NSArray *)find:(SWFindSpecification)spec;

+ (NSArray *)find:(SWFindSpecification)spec andConnection:(id<SWConnection>)aConnection;

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql;

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql
	   connection:(id<SWConnection>)aConnection;

+ (NSArray *)find:(SWFindSpecification)spec filter:(NSString *)whereSql
			 join:(NSString *)joinSql order:(NSString *)orderSql limit:(NSUInteger)limit;

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql
		   filter:(NSString *)filterSql join:(NSString *)joinSql
			order:(NSString *)orderSql limit:(NSUInteger)limit;

+ (NSArray *)find:(SWFindSpecification)spec filter:(NSString *)whereSql 
			 join:(NSString *)joinSql order:(NSString *)orderSql 
			limit:(NSUInteger)limit connection:(id<SWConnection>)aConnection;

+ (NSArray *)find:(SWFindSpecification)spec select:(NSString *)selectSql
		   filter:(NSString *)filterSql join:(NSString *)joinSql
			order:(NSString *)orderSql limit:(NSUInteger)limit
	   connection:(id<SWConnection>)aConnection;

/**
 * finds ids of records matching the find specification, filter and limit using
 * the specified connection.
 * @param selectSql A valid SQL SELECT statement (omitting the "SELECT")
 * @param whereSql  A valid SQL WHERE statement (omitting the "WHERE")
 * @param orderSql  A valid SQL ORDER statement (omitting the "ORDER BY")
 * @param limit     The maximum number of records to retrieve
 * @param connection The connection to use for the records. (pass nil to use default connection)
 */
+ (NSArray *)findIds:(SWFindSpecification)spec select:(NSString *)selectSql
			  filter:(NSString *)whereSql join:(NSString *)joinSql
			   order:(NSString *)orderSql limit:(NSUInteger)limit
		  connection:(id<SWConnection>)aConnection;

+ (NSArray *)findIds:(SWFindSpecification)spec filter:(NSString *)whereSql 
				join:(NSString *)joinSql order:(NSString *)orderSql 
			   limit:(NSUInteger)limit connection:(id <SWConnection>)aConnection;

@end
