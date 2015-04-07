//
//  CoreGraphics+Additions.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     */
    CGPoint CGPointOffset(CGPoint point, CGFloat x, CGFloat y);
    
    CGFloat CKCGAffineTransformGetScaleX(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetScaleY(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetShearX(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetShearY(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetTranslateX(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetTranslateY(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetFlip(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetScaleX0(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetScaleY0(CGAffineTransform transform);
    CGFloat CKCGAffineTransformGetRotation(CGAffineTransform transform);
    
    //ratio between 0 and 1 interpolate from t1 to t2
    CGAffineTransform CKCGAffineTransformInterpolate(CGAffineTransform t1,CGAffineTransform t2, CGFloat ratio);
    
    CGRect CKCGRectInterpolate(CGRect r1,CGRect r2, CGFloat ratio);
    CGFloat CKCGFloatInterpolate(CGFloat f1,CGFloat f2, CGFloat ratio);
    CGPoint CKCGRectCenter(CGRect rect);

#ifdef __cplusplus
}
#endif