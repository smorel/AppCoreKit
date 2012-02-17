//
//  CKCGAffineTransform+Additions.m
//  CloudKit
//
//  Created by Martin Dufort on 12-02-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKCGAffineTransform+Additions.h"

#define _sign(value) (value >=0 ) ? 1 : -1

CGFloat a, b, c, d;
CGFloat tx, ty;

CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform) {
    return transform.a;
}

CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform) {
    return transform.d;
}

CGFloat CGAffineTransformGetShearX(CGAffineTransform transform) {
    return transform.b;
}

CGFloat CGAffineTransformGetShearY(CGAffineTransform transform) {
    return transform.c;
}

CGFloat CGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

CGFloat CGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

CGFloat CGAffineTransformGetFlip(CGAffineTransform transform) {
    CGFloat scaleX = _sign(CGAffineTransformGetScaleX(transform));
    CGFloat scaleY = _sign(CGAffineTransformGetScaleY(transform));
    CGFloat shearX = _sign(CGAffineTransformGetShearX(transform));
    CGFloat shearY = _sign(CGAffineTransformGetShearY(transform));
    if (scaleX ==  scaleY && shearX == -shearY) return +1;
    if (scaleX == -scaleY && shearX ==  shearY) return -1;
    return 0;
}

CGFloat CGAffineTransformGetScaleX0(CGAffineTransform transform) {
    CGFloat scale = CGAffineTransformGetScaleX(transform);
    CGFloat shear = CGAffineTransformGetShearX(transform);
    if (shear == 0) return fabs(scale);  // Optimization for a very common case.
    if (scale == 0) return fabs(shear);  // Not as common as above, but still common enough.
    return hypotf(scale, shear);
}

CGFloat CGAffineTransformGetScaleY0(CGAffineTransform transform) {
    CGFloat scale = CGAffineTransformGetScaleY(transform);
    CGFloat shear = CGAffineTransformGetShearY(transform);
    if (shear == 0) return fabs(scale);  // Optimization for a very common case.
    if (scale == 0) return fabs(shear);  // Not as common as above, but still common enough.
    return hypotf(scale, shear);
}

CGFloat CGAffineTransformGetRotation(CGAffineTransform transform) {
    CGFloat flip = CGAffineTransformGetFlip(transform);
    if (flip != 0) {
        CGFloat scaleX = CGAffineTransformGetScaleX0(transform);
        CGFloat scaleY = CGAffineTransformGetScaleY0(transform) * flip;
        
        return atan2((CGAffineTransformGetShearY(transform)/scaleY) - (CGAffineTransformGetShearX(transform)/scaleX),
                     (CGAffineTransformGetScaleY(transform)/scaleY) + (CGAffineTransformGetScaleX(transform)/scaleX));
    }
    return 0;
}

CGAffineTransform CGAffineTransformInterpolate(CGAffineTransform t1,CGAffineTransform t2, CGFloat ratio){
    CGFloat scaleX1 = CGAffineTransformGetScaleX(t1);
    CGFloat scaleX2 = CGAffineTransformGetScaleX(t2);
    CGFloat scaleY1 = CGAffineTransformGetScaleY(t1);
    CGFloat scaleY2 = CGAffineTransformGetScaleY(t2);
    CGFloat scaleTx1 = CGAffineTransformGetTranslateX(t1);
    CGFloat scaleTx2 = CGAffineTransformGetTranslateX(t2);
    CGFloat scaleTy1 = CGAffineTransformGetTranslateY(t1);
    CGFloat scaleTy2 = CGAffineTransformGetTranslateY(t2);
    CGFloat rot1 = CGAffineTransformGetRotation(t1);
    CGFloat rot2 = CGAffineTransformGetRotation(t2);
    
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleX1 + ((scaleX2 - scaleX1) * ratio), scaleY1 + ((scaleY2 - scaleY1) * ratio));
    CGAffineTransform translate = CGAffineTransformMakeScale(scaleTx1 + ((scaleTx2 - scaleTx1) * ratio), scaleTy1 + ((scaleTy2 - scaleTy1) * ratio));
    CGAffineTransform rotate = CGAffineTransformMakeRotation(rot1 + ((rot2 - rot1) * ratio));
    
    return CGAffineTransformConcat(CGAffineTransformConcat(scale, rotate),translate);
}