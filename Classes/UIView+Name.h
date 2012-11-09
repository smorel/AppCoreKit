//
//  UIView+Name.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIView (Factory)

///-----------------------------------
/// @name Identifying view at runtime
///-----------------------------------

/** Returns an autoreleased view object
 */
+ (id)view;

/** Returns an autoreleased view object initialized using the specified frame
 */
+ (id)viewWithFrame:(CGRect)frame;

@end

/**
 */
@interface UIView (CKName)

///-----------------------------------
/// @name Identifying view at runtime
///-----------------------------------

/**
 */
@property (nonatomic,copy) NSString* name;

///-----------------------------------
/// @name Querying view hierarchy
///-----------------------------------

/**
 */
- (id)viewWithKeyPath:(NSString*)keyPath;

@end


@interface UIBarButtonItem (CKName)

///-----------------------------------
/// @name Identifying Bar button item at runtime
///-----------------------------------

/**
 */
@property (nonatomic,copy) NSString* name;

@end