//
//  CKCascadingTree.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* CKCascadingTreeFormats;
extern NSString* CKCascadingTreeParent;
extern NSString* CKCascadingTreeEmpty;
extern NSString* CKCascadingTreeNode;
extern NSString* CKCascadingTreeInherits;
extern NSString* CKCascadingTreeImport;
extern NSString* CKCascadingTreeIPad;
extern NSString* CKCascadingTreeIPhone;

/** TODO
 */
@interface CKCascadingTree : NSObject {
	NSMutableDictionary* _tree;
	NSMutableSet* _loadedFiles;
}
@property (nonatomic,retain,readonly) NSMutableDictionary* tree;

+ (CKCascadingTree*)treeWithContentOfFile:(NSString*)path;
- (id)initWithContentOfFile:(NSString*)path;
- (BOOL)loadContentOfFile:(NSString*)path;
- (BOOL)appendContentOfFile:(NSString*)path;

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName;
- (NSMutableDictionary*)dictionaryForKey:(id)key;
- (NSMutableDictionary*)dictionaryForClass:(Class)c;
- (NSArray*)arrayForKey:(id)key;

- (void)addDictionary:(NSMutableDictionary*)dictionary forKey:(id)key;
- (void)removeDictionaryForKey:(id)key;

@end

/** TODO
 */
@interface NSDictionary (CKCascadingTree)
- (BOOL)isReservedKeyWord:(NSString*)key;
@end

@interface NSMutableDictionary (CKCascadingTree)

- (NSMutableDictionary*)dictionaryForObject:(id)object propertyName:(NSString*)propertyName;
- (NSMutableDictionary*)dictionaryForClass:(Class)c;
- (NSMutableDictionary*)dictionaryForKey:(NSString*)key;

- (BOOL)isEmpty;
- (BOOL)containsObjectForKey:(NSString*)key;
- (NSString*)path;

@end