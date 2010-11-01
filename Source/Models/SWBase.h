//
//  SWBase.h
//  SimpleWrapper
//
//  Created by changwang on 10/25/10.
//  Copyright 2010 WMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleWrapper/SWConnection.h>

/**
 * will be used by find methods.
 */
typedef enum {
  SWFindFirst = 1,
  SWFindAll
} SWFindSpecification;

/**
 * This is the root class for SimpleWrapper models.
 * All models should inherit SWBase.
 * To use it, subclass it with a model name, e.g <prefix>Apple,
 * then SimpleWrapper will look for a table apple in database to map the model.
 */

@interface SWBase : NSObject {

  id<SWConnection> connection;
  NSUInteger lastID;
  BOOL isNew;
  
  // With this, after first time query,
  // there is no need to query the table any more.
  NSMutableArray *tableCache;
}

@property (nonatomic, readwrite, retain) id<SWConnection> connection;
@property (nonatomic) NSUInteger lastID;
@property (nonatomic) BOOL isNew;

/**
 * Create a new record based on the given attributes, save it to the database.
 */
+ (id)createWithAttributes:(NSDictionary *)attrs connection:(id<SWConnection>)connection;

/**
 * Returns the table name of the record based on the class name by converting
 * it to lowercase, pluralizing it and removing class prefix if existed.
 */
+ (NSString *)tableName;

- (id)initWithPk:(NSUInteger)pk;
/**
 * Initialize the records with a given connection and primary key.
 */
- (id)initWithConnection:(id<SWConnection>)aConnection pk:(NSUInteger)pk;

/**
 * All models should share a connection.
 */
+ (void)setDefaultConnection:(id<SWConnection>)aConnection;
+ (id<SWConnection>)defaultConnection;

/**
 * caches the column names.
 */
- (NSArray *)columns;
- (NSArray *)columnsWithoutPrimaryKey;

/**
 * saves the record to database.
 */
- (void)save;

/**
 * removes the record from database.
 */
- (BOOL)destory;

/**
 * empties the table.
 */
+ (BOOL)empty;

/**
 * counts the entries in the table.
 */
+ (NSUInteger)count;

@end
