//
//  CKReference.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-17.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CKItem;
@class CKAttribute;
@interface CKReference : NSManagedObject {
}

@property (nonatomic, retain) CKItem * item;
@property (nonatomic, retain) CKAttribute * parentAttribute;
@end
