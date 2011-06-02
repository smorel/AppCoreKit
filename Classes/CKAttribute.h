//
//  CKAttribute.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CKItem;

@interface CKAttribute : NSManagedObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) CKItem *item;
@property (nonatomic, retain) NSSet* items;

@end


@interface CKAttribute (CoreDataGeneratedAccessors)
- (void)addItemsObject:(CKItem *)value;
- (void)removeItemsObject:(CKItem *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end
