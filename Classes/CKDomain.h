//
//  CKDomain.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CKItem.h"

@interface CKDomain : NSManagedObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSSet *items;

@end

@interface CKDomain (CKDomainAccessors)

- (void)addItemsObject:(CKItem *)value;
- (void)removesItemsObject:(CKItem *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end