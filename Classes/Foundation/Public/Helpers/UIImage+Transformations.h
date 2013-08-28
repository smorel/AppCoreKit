//
//  UIImage+Transformations.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 */
static void CKCGAddRoundedRectToPath(CGContextRef gc, CGRect rect, CGFloat radius);


/**
 */
@interface UIImage (CKUIImageTransformationsAdditions)

///-----------------------------------
/// @name Transforming an Image
///-----------------------------------

/** 
 */
- (UIImage *)imageThatFits:(CGSize)size crop:(BOOL)crop;

/** 
 */
- (UIImage *)imageByAddingBorderWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end
