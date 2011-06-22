//
//  CKWeakRef.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCallback.h"


@interface CKWeakRef : NSObject {
	id _object;
	CKCallback* _callback;
}

@property(nonatomic,assign)id object;

- (id)initWithObject:(id)object;
- (id)initWithObject:(id)object callback:(CKCallback*)callback;
- (id)initWithObject:(id)object block:(void (^)(id object))block;
- (id)initWithObject:(id)object target:(id)target action:(SEL)action;

+ (CKWeakRef*)weakRefWithObject:(id)object;
+ (CKWeakRef*)weakRefWithObject:(id)object callback:(CKCallback*)callback;
+ (CKWeakRef*)weakRefWithObject:(id)object block:(void (^)(id object))block;
+ (CKWeakRef*)weakRefWithObject:(id)object target:(id)target action:(SEL)action;

@end