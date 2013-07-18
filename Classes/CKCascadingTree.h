//
//  CKCascadingTree.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const CKCascadingTreeFormats;
extern NSString* const CKCascadingTreeParent;
extern NSString* const CKCascadingTreeEmpty;
extern NSString* const CKCascadingTreeNode;
extern NSString* const CKCascadingTreeInherits;
extern NSString* const CKCascadingTreeImport;
extern NSString* const CKCascadingTreeIPad;
extern NSString* const CKCascadingTreeIPhone;

//extern NSString * const CKCascadingTreeFilesDidUpdateNotification;

/**
 */
@interface CKCascadingTree : NSObject 

///-----------------------------------
/// @name Creating Cascading Tree Objects
///-----------------------------------

/**
 */
+ (CKCascadingTree*)treeWithContentOfFile:(NSString*)path;

///-----------------------------------
/// @name Initializing Cascading Tree Objects
///-----------------------------------

/**
 */
- (id)initWithContentOfFile:(NSString*)path;

///-----------------------------------
/// @name Importing files
///-----------------------------------

/**
 */
- (BOOL)loadContentOfFile:(NSString*)path;

/**
 */
- (BOOL)appendContentOfFile:(NSString*)path;

- (void)reloadAfterFileUpdate;

///-----------------------------------
/// @name Accessing Cascading tree content
///-----------------------------------

/**
 */
@property (nonatomic,retain,readonly) NSMutableDictionary* tree;

///-----------------------------------
/// @name Querying Cascading tree
///-----------------------------------

/**
 */
- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName;

/**
 */
- (NSMutableDictionary*)dictionaryForKey:(id)key;

/**
 */
- (NSMutableDictionary*)dictionaryForClass:(Class)c;

///-----------------------------------
/// @name Inserting or Removing cascading tree content
///-----------------------------------

/**
 */
- (void)addDictionary:(NSMutableDictionary*)dictionary forKey:(id)key;

/**
 */
- (void)removeDictionaryForKey:(id)key;

@end

/**
 */
@interface NSMutableDictionary (CKCascadingTree)

///-----------------------------------
/// @name Querying Cascading tree Dictionary
///-----------------------------------

/**
 */
- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName;

/**
 */
- (NSMutableDictionary*)dictionaryForClass:(Class)c;

/**
 */
- (NSMutableDictionary*)dictionaryForKey:(NSString*)key;

/**
 */
- (BOOL)isEmpty;

/**
 */
- (BOOL)containsObjectForKey:(NSString*)key;

///-----------------------------------
/// @name Debugging Cascading tree Dictionary
///-----------------------------------

/**
 */
- (NSString*)path;

@end