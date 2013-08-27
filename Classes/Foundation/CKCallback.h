//
//  CKCallback.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^CKCallbackBlock)(id value);

/** 
 Callback mechanism. A CKCallback is a wrapper on top of a block or target action that can embed userinfos. Calling execute on a callback will execute the associated block or action with some parameters and access to the userinfos.
 
        CKCallback* callback = [CKCallback callbackWithBlock:^(id object){
            //do something when callback execute is called
 
            id returnValue = ...;
            return returnValue;
        }];
 
        [callback execute:someObject];
 
 */
@interface CKCallback : NSObject

///-----------------------------------
/// @name Setuping the callback
///-----------------------------------

/** target
 */
@property(nonatomic,assign) id target;

/** action
 */
@property(nonatomic,assign) SEL action;

/** block
 */
@property(nonatomic,copy) CKCallbackBlock block;

/** user infos
 */
@property(nonatomic,copy) NSArray* params;

///-----------------------------------
/// @name Creating and Initializing Callbacks
///-----------------------------------

/** test
 @param block The block that will get executed when callback execute: will gets called.
 */
+ (CKCallback*)callbackWithBlock:(CKCallbackBlock)block;

/** test
 @param target The target on wich action will get executed when callback execute: will gets called.
 @param action The selector that will get called on target when callback execute: will gets called.
 */
+ (CKCallback*)callbackWithTarget:(id)target action:(SEL)action;

/** test
 @param block The block that will get executed when callback execute: will gets called.
 */
- (id)initWithBlock:(CKCallbackBlock)block;

/** test
 @param target The target on wich action will get executed when callback execute: will gets called.
 @param action The selector that will get called on target when callback execute: will gets called.
 */
- (id)initWithTarget:(id)target action:(SEL)action;


///-----------------------------------
/// @name Executing Callbacks
///-----------------------------------

/** test
 @param object The object to pass to the associated block or action
 */
- (id)execute:(id)object;

@end