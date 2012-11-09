//
//  CKWeakRef.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCallback.h"

/** 
 Weak reference with dealloc callback mechanism. A [weak ref](CKWeakRef) allow to reference an object without retaining it. You can optionally register a [callback](CKCallback) to execute some code when the object is deallocated. When the object is deallocated, the object property of the [weak ref](CKWeakRef) is set to nil. By this way, you can safelly call [myRef object] with no crash.
 
        CKWeakRef* ref = [CKWeakRef weakRefWithObject:theObject block:^(id object){
            //Do something when theObject is deallocated
        }];
 
 */
@interface CKWeakRef : NSObject <NSCopying> 

///-----------------------------------
/// @name Managing the referenced object
///-----------------------------------

/** 
 */
@property(nonatomic,assign)id object;

///-----------------------------------
/// @name Creating and Initializing WeakRefs
///-----------------------------------

/** test
 @param object The target.
 @see object
 */
- (id)initWithObject:(id)object;

/** test
 @param object The target.
 @param callback The callback to execute when object is deallocated.
 @see object
 @see CKCallback
 */
- (id)initWithObject:(id)object callback:(CKCallback*)callback;


/** test
 @param object The target.
 @param target The target on wich action will be executed when object is deallocated.
 @param action The selector to execute on target when object is deallocated.
 @see object
 */
- (id)initWithObject:(id)object target:(id)target action:(SEL)action;

/** test
 @param object The target.
 @param block The block to execute when object is deallocated.
 @see object
 */
- (id)initWithObject:(id)object block:(void (^)(CKWeakRef* weakRef))block;

/** test
 @param object The target.
 @see object
 */
+ (CKWeakRef*)weakRefWithObject:(id)object;

/** test
 @param object The target.
 @param callback The callback to execute when object is deallocated.
 @see object
 @see CKCallback
 */
+ (CKWeakRef*)weakRefWithObject:(id)object callback:(CKCallback*)callback;

/** test
 @param object The target.
 @param block The block to execute when object is deallocated.
 @see object
 */
+ (CKWeakRef*)weakRefWithObject:(id)object block:(void (^)(CKWeakRef* weakRef))block;//object is the weakref ...

/** test
 @param object The target.
 @param target The target on wich action will be executed when object is deallocated.
 @param action The selector to execute on target when object is deallocated.
 @see object
 */
+ (CKWeakRef*)weakRefWithObject:(id)object target:(id)target action:(SEL)action;

@end
