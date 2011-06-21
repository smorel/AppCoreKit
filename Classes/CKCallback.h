//
//  CKCallback.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-13.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^CKCallbackBlock)(id value);
@interface CKCallback : NSObject{
	id _target;
	SEL _action;
	CKCallbackBlock _block;
	NSArray* _params;
}

@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL action;
@property(nonatomic,copy) CKCallbackBlock block;
@property(nonatomic,copy) NSArray* params;

+ (CKCallback*)callbackWithBlock:(CKCallbackBlock)block;
+ (CKCallback*)callbackWithTarget:(id)target action:(SEL)action;

- (id)initWithTarget:(id)target action:(SEL)action;
- (id)initWithBlock:(CKCallbackBlock)block;
- (id)execute:(id)object;

@end