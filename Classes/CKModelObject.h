//
//  NFBObject.h
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Introspection.h"

typedef void(^CKModelObjectBlock)(CKObjectProperty*,id);

@interface CKModelObject : NSObject<NSCoding,NSCopying> {

}

- (void)executeForAllProperties:(CKModelObjectBlock)block;

@end
