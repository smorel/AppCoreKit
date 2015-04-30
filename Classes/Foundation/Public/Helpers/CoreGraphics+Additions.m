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
    p1 = CKCGPointNormalize(p1);
    p2 = CKCGPointNormalize(p2);
    
    CGFloat l1 = CKCGPointLength(p1);
    CGFloat l2 = CKCGPointLength(p2);
    CGFloat C = (p1.x*p2.x+p1.y*p2.y)/(l1*l2);
    CGFloat S = (p1.x*p2.y-p2.x*p1.y);
    CGFloat sign = (S >= 0) ? 1 : -1;
    CGFloat angle = sign*acos(C);
    return angle;
}

CGPoint CKCGPointIntersectHorizontalEdge(CGFloat y,CGPoint lineOrigin, CGPoint lineDirection){
    CGFloat beta = CKCGPointAngle( CGPointMake(1, 0), lineDirection);
    
    CGFloat b = y - lineOrigin.y;
    CGFloat c = b / sin(beta);
    CGFloat a = c * cos(beta);

    return CGPointMake(a + lineOrigin.x,y);
}

CGPoint CKCGPointIntersectVerticalEdge(CGFloat x,CGPoint lineOrigin, CGPoint lineDirection){
    CGFloat beta = CKCGPointAngle( CGPointMake(1, 0), lineDirection);
    
    CGFloat a = x - lineOrigin.x;
    CGFloat c = a / cos(beta);
    CGFloat b = c * sin(beta);
    
    return CGPointMake(x,b + lineOrigin.y);
}

CGPoint CKCGRectIntersect(CGRect r, CGPoint origin, CGPoint direction){
    direction = CKCGPointNormalize(direction);
    
    CGPoint nearest = CGPointInfinite;
    CGFloat nearestDistance = MAXFLOAT;
    
    NSMutableArray* intersecting = [NSMutableArray array];
    
    CGPoint top  = CKCGPointIntersectHorizontalEdge(r.origin.y,
                                                             origin,
                                                             direction);
    if(top.x >= r.origin.x && top.x <= (r.origin.x + r.size.width)){
        [intersecting addObject:[NSValue valueWithCGPoint:top]];
    }
    
    CGPoint left  = CKCGPointIntersectVerticalEdge(r.origin.x,
                                                            origin,
                                                            direction);
    
    if(left.y >= r.origin.y && left.y <= (r.origin.y + r.size.height)){
        [intersecting addObject:[NSValue valueWithCGPoint:left]];
    }
    
    CGPoint bottom  = CKCGPointIntersectHorizontalEdge(r.origin.y + r.size.height,
                                                              origin,
                                                              direction);
    
    if(bottom.x >= r.origin.x && bottom.x <= (r.origin.x + r.size.width))
    {
        [intersecting addObject:[NSValue valueWithCGPoint:bottom]];
    }
    
    CGPoint right  = CKCGPointIntersectVerticalEdge(r.origin.x + r.size.width,
                                                            origin,
                                                            direction);
    
    if(right.y >= r.origin.y && right.y <= (r.origin.y + r.size.height))
    {
        [intersecting addObject:[NSValue valueWithCGPoint:right]];
    }
    
    
    if(intersecting.count > 0){
        CGFloat nearestDistance = MAXFLOAT;
        CGPoint nearest = CGPointInfinite;
        
        for(NSValue* v in intersecting){
            CGPoint point = [v CGPointValue];
            CGPoint fromLight = CGPointMake(point.x - origin.x,point.y-origin.y);
            CGFloat length = CKCGPointLength(fromLight);
            if(length < nearestDistance){
                nearestDistance = length;
                nearest = point;
            }
        }
        
        return CGPointMake(nearest.x - r.origin.x,nearest.y - r.origin.y);
    }
    
    CGPoint diff = CGPointMake(r.origin.x + (r.size.width/2) - origin.x, r.origin.y  + (r.size.height/2) - origin.y);
    
    if(diff.x > 0 && diff.y > 0){
        if(top.x - r.origin.x > 0){
            return CGPointMake(top.x - r.origin.x,top.y - r.origin.y);
        }else{
            return CGPointMake(left.x - r.origin.x,left.y - r.origin.y);
        }
    }else if(diff.x < 0 && diff.y > 0){
        if(right.y - r.origin.y > 0){
            return CGPointMake(right.x - r.origin.x,right.y - r.origin.y);
        }else {
            return CGPointMake(top.x - r.origin.x,top.y - r.origin.y);
        }
    }else if(diff.x > 0 && diff.y < 0){
        if(bottom.x - r.origin.x > 0){
            return CGPointMake(bottom.x - r.origin.x,bottom.y - r.origin.y);
        }else{
            return CGPointMake(left.x - r.origin.x,left.y - r.origin.y);
        }
    }else{
        if(right.y - r.origin.y > 0){
            return CGPointMake(right.x - r.origin.x,right.y - r.origin.y);
        }else {
            return CGPointMake(bottom.x - r.origin.x,bottom.y - r.origin.y);
        }
    }
    
    return CGPointInfinite;
 }
