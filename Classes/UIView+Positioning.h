//
//  UIView+Positioning.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIView (CKPositioning)

///-----------------------------------
/// @name Configuring the Bounds and Frame Rectangles
///-----------------------------------

/**
 */
@property(nonatomic,assign)CGFloat x;

/**
 */
@property(nonatomic,assign)CGFloat y;

/**
 */
@property(nonatomic,assign)CGFloat width;

/**
 */
@property(nonatomic,assign)CGFloat height;

@end

/**
 */
@interface UIView(Snaphot)

/**
 */
- (UIImage*)snapshot;

@end