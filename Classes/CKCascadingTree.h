//
//  CKCascadingTree.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-21.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface CKCascadingTree : NSObject {
	NSMutableDictionary* _tree;
	NSMutableSet* _loadedFiles;
}

+ (CKCascadingTree*)treeWithContentOfFile:(NSString*)path;
- (id)initWithContentOfFile:(NSString*)path;
- (BOOL)loadContentOfFile:(NSString*)path;
- (BOOL)appendContentOfFile:(NSString*)path;

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName;
- (NSMutableDictionary*)dictionaryForKey:(NSString*)key;
- (NSMutableDictionary*)dictionaryForClass:(Class)c;

@end

/** TODO
 */
@interface NSDictionary (CKCascadingTree)
- (BOOL)isReservedKeyWord:(NSString*)key;
@end

@interface NSMutableDictionary (CKCascadingTree)

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName;
- (NSMutableDictionary*)dictionaryForClass:(Class)c;

- (BOOL)isEmpty;
- (BOOL)containsObjectForKey:(NSString*)key;

@end