//
//  CKAttribute.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CKItem;

@interface CKAttribute : NSManagedObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) CKItem *item;
@property (nonatomic, retain) NSSet* itemReferences;
@property (nonatomic, readonly) NSArray* items;

@end

@interface CKAttribute (CoreDataGeneratedAccessors)
- (void)addItemReferencesObject:(NSManagedObject *)value;
- (void)removeItemReferencesObject:(NSManagedObject *)value;
- (void)addItemReferences:(NSSet *)value;
- (void)removeItemReferences:(NSSet *)value;

@end
