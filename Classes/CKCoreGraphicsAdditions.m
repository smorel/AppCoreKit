//
//  CKCoreGraphicsAdditions.m
//  CloudKit
//
//  Created by Olivier Collet on 11-01-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCoreGraphicsAdditions.h"
#import <QuartzCore/QuartzCore.h>


CGPoint CGPointOffset(CGPoint point, CGFloat x, CGFloat y) {
	CGPoint newPoint = point;
	newPoint.x += x;
	newPoint.y += y;
	return newPoint;
}

#define _sign(value) (value >=0 ) ? 1 : -1

CGFloat CKCGAffineTransformGetScaleX(CGAffineTransform transform) {
    return transform.a;
}

CGFloat CKCGAffineTransformGetScaleY(CGAffineTransform transform) {
    return transform.d;
}

CGFloat CKCGAffineTransformGetShearX(CGAffineTransform transform) {
    return transform.b;
}

CGFloat CKCGAffineTransformGetShearY(CGAffineTransform transform) {
    return transform.c;
}

CGFloat CKCGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

CGFloat CKCGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

CGFloat CGAffineTransformGetFlip(CGAffineTransform transform) {
    CGFloat scaleX = _sign(CKCGAffineTransformGetScaleX(transform));
    CGFloat scaleY = _sign(CKCGAffineTransformGetScaleY(transform));
    CGFloat shearX = _sign(CKCGAffineTransformGetShearX(transform));
    CGFloat shearY = _sign(CKCGAffineTransformGetShearY(transform));
    if (scaleX ==  scaleY && shearX == -shearY) return +1;
    if (scaleX == -scaleY && shearX ==  shearY) return -1;
    return 0;
}

CGFloat CKCGAffineTransformGetScaleX0(CGAffineTransform transform) {
    CGFloat scale = CKCGAffineTransformGetScaleX(transform);
    CGFloat shear = CKCGAffineTransformGetShearX(transform);
    if (shear == 0) return fabs(scale);  // Optimization for a very common case.
    if (scale == 0) return fabs(shear);  // Not as common as above, but still common enough.
    return hypotf(scale, shear);
}

CGFloat CKCGAffineTransformGetScaleY0(CGAffineTransform transform) {
    CGFloat scale = CKCGAffineTransformGetScaleY(transform);
    CGFloat shear = CKCGAffineTransformGetShearY(transform);
    if (shear == 0) return fabs(scale);  // Optimization for a very common case.
    if (scale == 0) return fabs(shear);  // Not as common as above, but still common enough.
    return hypotf(scale, shear);
}

CGFloat CKCGAffineTransformGetRotation(CGAffineTransform transform) {
    CGFloat flip = CGAffineTransformGetFlip(transform);
    if (flip != 0) {
        CGFloat scaleX = CKCGAffineTransformGetScaleX0(transform);
        CGFloat scaleY = CKCGAffineTransformGetScaleY0(transform) * flip;
        
        return atan2((CKCGAffineTransformGetShearY(transform)/scaleY) - (CKCGAffineTransformGetShearX(transform)/scaleX),
                     (CKCGAffineTransformGetScaleY(transform)/scaleY) + (CKCGAffineTransformGetScaleX(transform)/scaleX));
    }
    return 0;
}

CGAffineTransform CKCGAffineTransformInterpolate(CGAffineTransform t1,CGAffineTransform t2, CGFloat ratio){
    if(CGAffineTransformEqualToTransform(t1, t2)){
        return t1;
    }
    
    CGAffineTransform t;
    t.a = t1.a + ((t2.a - t1.a) * ratio);
    t.b = t1.b + ((t2.b - t1.b) * ratio);
    t.c = t1.c + ((t2.c - t1.c) * ratio);
    t.d = t1.d + ((t2.d - t1.d) * ratio);
    t.tx = t1.tx + ((t2.tx - t1.tx) * ratio);
    t.ty = t1.ty + ((t2.ty - t1.ty) * ratio);
    return t;
}