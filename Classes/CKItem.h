//
//  CKItem.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CKDomain;
@class CKAttribute;

@interface CKItem : NSManagedObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) CKDomain *domain;
@property (nonatomic, retain) NSSet *attributes;

@end

@interface CKItem (CKItemAccessors)

- (void)addAttributesObject:(CKAttribute *)value;
- (void)removeAttributesObject:(CKAttribute *)value;
- (void)addAttributes:(NSSet *)value;
- (void)removeAttributes:(NSSet *)value;

- (NSDictionary *)attributesAsDictionary;

@end