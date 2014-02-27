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

/**
 */
- (BOOL)hasSuperviewWithClass:(Class)type;

@end

/**
 */
@interface UIView(Snaphot)

/**
 */
- (UIImage*)snapshot;

@end

/**
 */
@interface UIScrollView(Snaphot)

/**
 */
- (UIImage*)snapshot;

@end


/**
 */
@interface UIScreen(Snaphot)

/** Only works on ios7 and more
 */
- (UIImage*)snapshot;

@end