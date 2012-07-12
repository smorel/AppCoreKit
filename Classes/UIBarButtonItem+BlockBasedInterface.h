//
//  UIBarButtonItem+BlockBasedInterface.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Bindings.h"

typedef void(^UIBarButtonItemExecutionBlock)();


/** 
 */
@interface UIBarButtonItem (CKAdditions)

///-----------------------------------
/// @name Initializing Bar Button Item Objects
///-----------------------------------

/**
 */
- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style block:(void(^)())block;

/**
 */
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style block:(void(^)())block;

/**
 */
- (id)initWithTag:(NSInteger)tag style:(UIBarButtonItemStyle)style block:(void(^)())block;

/**
 */
- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem block:(void(^)())block;

///-----------------------------------
/// @name Managing execution block
///-----------------------------------

/**
 */
@property(nonatomic,copy) UIBarButtonItemExecutionBlock block;

///-----------------------------------
/// @name Getting Bar Button Item Information
///-----------------------------------

/**
 */
@property(nonatomic,retain) id userData;


///-----------------------------------
/// @name Bindings
///-----------------------------------

/**
 */
- (void)bindEventWithBlock:(void(^)())block;

@end
