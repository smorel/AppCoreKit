//
//  NFBObject.h
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Introspection.h"

typedef void(^CKModelObjectBlock)(CKObjectProperty*,id);

@protocol CKMigrating
- (void)propertyClassChanged:(CKObjectProperty*)property serializedObject:(id)object;
- (void)propertyDisappear:(NSString*)propertyName serializedObject:(id)object;
- (void)propertyAdded:(CKObjectProperty*)property;
@end

@interface CKModelObject : NSObject<NSCoding,NSCopying,CKMigrating> {

}

- (void)executeForAllProperties:(CKModelObjectBlock)block;

@end
