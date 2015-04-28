//
//  CoreGraphics+Additions.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CoreGraphics+Additions.h"
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


CGPoint CKCGRectCenter(CGRect rect){
    CGPoint point;
    point.x = rect.origin.x + (rect.size.width / 2.0f);
    point.y = rect.origin.y + (rect.size.height / 2.0f);
    return point;
}

CGRect CKCGRectInterpolate(CGRect r1,CGRect r2, CGFloat ratio){
    CGRect r;
    r.origin.x = r1.origin.x + ((r2.origin.x - r1.origin.x) * ratio);
    r.origin.y = r1.origin.y + ((r2.origin.y - r1.origin.y) * ratio);
    r.size.width = r1.size.width + ((r2.size.width - r1.size.width) * ratio);
    r.size.height = r1.size.height + ((r2.size.height - r1.size.height) * ratio);
    return r;
}


CGFloat CKCGFloatInterpolate(CGFloat f1,CGFloat f2, CGFloat ratio){
    return f1 + ((f2 - f1) * ratio);
}

CGFloat CKCGPointLength(CGPoint point){
    return sqrt((point.x * point.x) + (point.y * point.y));;
}

CGPoint CKCGPointNormalize(CGPoint point){
    CGFloat length = CKCGPointLength(point);
    return CGPointMake((length == 0) ? 1 : (point.x / length), (length == 0) ? 1 : (point.y/length));
}

CGFloat CKCGPointAngle(CGPoint p1,CGPoint p2){
    CGFloat l1 = CKCGPointLength(p1);
    CGFloat l2 = CKCGPointLength(p2);
    CGFloat C = (p1.x*p2.x+p1.y*p2.y)/(l1*l2);
    CGFloat S = (p1.x*p2.y-p2.x*p1.y);
    CGFloat sign = (S >= 0) ? 1 : -1;
    CGFloat angle = sign*acos(C);
    return angle;
}

CGPoint CKCGPointIntersect(CGPoint origin1,CGPoint direction1,CGPoint origin2, CGPoint direction2){
    
    CGPoint p1 = origin1;
    CGPoint p2 = CGPointMake(origin1.x +  direction1.x,origin1.y +  direction1.y);
    
    CGPoint p3 = origin2;
    CGPoint p4 = CGPointMake(origin2.x + direction2.x,origin2.y +  direction2.y);
    
    CGFloat d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0)
        return CGPointInfinite; // parallel lines
    CGFloat u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    CGFloat v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
     if (u < 0.0 || u > 1.0)
         return CGPointInfinite; // intersection point not between p1 and p2
     if (v < 0.0 || v > 1.0)
        return CGPointInfinite; // intersection point not between p3 and p4
    
    CGPoint intersection;
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + v * (p2.y - p1.y);
    
    return intersection;
}


CGPoint CKCGRectIntersect(CGRect rect, CGPoint origin, CGPoint direction){
    CGPoint nearest = CGPointInfinite;
    CGFloat nearestDistance = MAXFLOAT;
    
    CGPoint top  = CKCGPointIntersect(rect.origin,
                                              CGPointMake(2*rect.size.width,0),
                                              origin,
                                              direction);
    CGFloat topDistance = CKCGPointLength(CGPointMake(origin.x - top.x, origin.y - top.y));
    if(topDistance < nearestDistance){ nearest = top; nearestDistance =  topDistance;}
    
    CGPoint left = CKCGPointIntersect(rect.origin,
                                      CGPointMake(0,2*rect.size.height),
                                      origin,
                                      direction);
    CGFloat leftDistance = CKCGPointLength(CGPointMake(origin.x - left.x, origin.y - left.y));
    if(leftDistance < nearestDistance){ nearest = left; nearestDistance =  leftDistance;}
    
    
    CGPoint bottom = CKCGPointIntersect(CGPointMake(rect.origin.x,rect.origin.y + rect.size.height),
                                      CGPointMake(2*rect.size.width,0),
                                      origin,
                                        direction);
    CGFloat bottomDistance = CKCGPointLength(CGPointMake(origin.x - bottom.x, origin.y - bottom.y));
    if(bottomDistance < nearestDistance){ nearest = bottom; nearestDistance =  bottomDistance;}
    
    
    CGPoint right = CKCGPointIntersect(CGPointMake(rect.origin.x + rect.size.width,rect.origin.y),
                                      CGPointMake(0,2*rect.size.height),
                                      origin,
                                       direction);
    CGFloat rightDistance = CKCGPointLength(CGPointMake(origin.x - right.x, origin.y - right.y));
    if(rightDistance < nearestDistance){ nearest = right; nearestDistance =  rightDistance;}
    
    
    
    if(CGPointEqualToPoint(nearest, CGPointInfinite))
        return nearest;
    
    return CGPointMake(nearest.x - rect.origin.x,nearest.y - rect.origin.y);
}
