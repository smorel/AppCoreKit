//
//  CKWeakRef.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCallback.h"

/** Weak reference with dealloc callback mechanism.
  * A CKWeakRef allow to reference objects in a weak way and setup a callback that will get called when the target object is deallocated.
  *
  *         CKWeakRef* ref = [CKWeakRef weakRefWithObject:theObject block:^(id object){
  *             //Do something when theObject is deallocated
  *         }];
  */
@interface CKWeakRef : NSObject {
	id _object;
	CKCallback* _callback;
}

/** property test
 */
@property(nonatomic,assign)id object;

///-----------------------------------
/// @name Creating and Initializing WeakRefs
///-----------------------------------

/** test
 */
- (id)initWithObject:(id)object;

/** tests2
 */
- (id)initWithObject:(id)object callback:(CKCallback*)callback;
- (id)initWithObject:(id)object block:(void (^)(id object))block;
- (id)initWithObject:(id)object target:(id)target action:(SEL)action;

+ (CKWeakRef*)weakRefWithObject:(id)object;
+ (CKWeakRef*)weakRefWithObject:(id)object callback:(CKCallback*)callback;
+ (CKWeakRef*)weakRefWithObject:(id)object block:(void (^)(id object))block;
+ (CKWeakRef*)weakRefWithObject:(id)object target:(id)target action:(SEL)action;

@end

