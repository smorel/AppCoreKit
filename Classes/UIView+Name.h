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
