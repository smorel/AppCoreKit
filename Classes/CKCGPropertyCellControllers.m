//
//  CKCGPropertyCellControllers.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCGPropertyCellControllers.h"
#import "CKObjectProperty.h"
#import <CoreLocation/CoreLocation.h>

//CGSIZE

@interface CGSizeWrapper : NSObject{}
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@end
@implementation CGSizeWrapper
@synthesize width,height;
@end

@implementation CKCGSizePropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[CGSizeWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CGSize size = [[p value]CGSizeValue];
	
	CGSizeWrapper* sizeWrapper = (CGSizeWrapper*)self.multiFloatValue;
	sizeWrapper.width = size.width;
	sizeWrapper.height = size.height;
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CGSizeWrapper* sizeWrapper = (CGSizeWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithCGSize:CGSizeMake(MAX(1,[sizeWrapper width]),MAX(1,[sizeWrapper height]))]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 2 * 44)];
}

@end

//CGPOINT

@interface CGPointWrapper : NSObject{}
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@end
@implementation CGPointWrapper
@synthesize x,y;
@end

@implementation CKCGPointPropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[CGPointWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CGPoint point = [[p value]CGPointValue];
	
	CGPointWrapper* pointWrapper = (CGPointWrapper*)self.multiFloatValue;
	pointWrapper.x = point.x;
	pointWrapper.y = point.y;
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CGPointWrapper* pointWrapper = (CGPointWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithCGPoint:CGPointMake(MAX(1,[pointWrapper x]),MAX(1,[pointWrapper y]))]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 2 * 44)];
}

@end

//CGRect

@interface CGRectWrapper : NSObject{}
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@end
@implementation CGRectWrapper
@synthesize x,y;
@synthesize width,height;
@end

@implementation CKCGRectPropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[CGRectWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CGRect rect = [[p value]CGRectValue];
	
	CGRectWrapper* rectWrapper = (CGRectWrapper*)self.multiFloatValue;
	rectWrapper.x = rect.origin.x;
	rectWrapper.y = rect.origin.y;
	rectWrapper.width = rect.size.width;
	rectWrapper.height = rect.size.height;
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CGRectWrapper* rectWrapper = (CGRectWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithCGRect:CGRectMake([rectWrapper x],[rectWrapper y],MAX(1,[rectWrapper width]),MAX(1,[rectWrapper height]))]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 4 * 44)];
}

@end

//UIEdgeInsets

@interface UIEdgeInsetsWrapper : NSObject{}
@property(nonatomic,assign)CGFloat top;
@property(nonatomic,assign)CGFloat left;
@property(nonatomic,assign)CGFloat bottom;
@property(nonatomic,assign)CGFloat right;
@end
@implementation UIEdgeInsetsWrapper
@synthesize top,left;
@synthesize bottom,right;
@end

@implementation CKUIEdgeInsetsPropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[UIEdgeInsetsWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	UIEdgeInsets insets = [[p value]UIEdgeInsetsValue];
	
	UIEdgeInsetsWrapper* insetsWrapper = (UIEdgeInsetsWrapper*)self.multiFloatValue;
	insetsWrapper.top = insets.top;
	insetsWrapper.left = insets.left;
	insetsWrapper.bottom = insets.bottom;
	insetsWrapper.right = insets.right;
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	UIEdgeInsetsWrapper* insetsWrapper = (UIEdgeInsetsWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([insetsWrapper top],[insetsWrapper left],[insetsWrapper bottom],[insetsWrapper right])]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 4 * 44)];
}

@end


//CGPOINT

@interface CLLocationCoordinate2DWrapper : NSObject{}
@property(nonatomic,assign)CGFloat latitude;
@property(nonatomic,assign)CGFloat longitude;
@end
@implementation CLLocationCoordinate2DWrapper
@synthesize latitude,longitude;
@end

@implementation CKCLLocationCoordinate2DPropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[CLLocationCoordinate2DWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CLLocationCoordinate2D coord;
    [[p value]getValue:&coord];
    
	CLLocationCoordinate2DWrapper* coordWrapper = (CLLocationCoordinate2DWrapper*)self.multiFloatValue;
    coordWrapper.latitude = coord.latitude;
    coordWrapper.longitude = coord.longitude;
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CLLocationCoordinate2DWrapper* coordWrapper = (CLLocationCoordinate2DWrapper*)self.multiFloatValue;
	
	CLLocationCoordinate2D coord;
	coord.latitude = coordWrapper.latitude;
	coord.longitude = coordWrapper.longitude;
	[p setValue:[NSValue value:&coord withObjCType:@encode(CLLocationCoordinate2D)]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 2 * 44)];
}

@end



//CGAffineTransform

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
        
        return atan2(CGAffineTransformGetShearY(transform)/scaleY - CGAffineTransformGetShearX(transform)/scaleX,
                    CGAffineTransformGetScaleY(transform)/scaleY + CGAffineTransformGetScaleX(transform)/scaleX);
    }
    return 0;
}

@interface CKCGAffineTransformWrapper : NSObject{}
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGFloat angle;
@property(nonatomic,assign)CGFloat scaleX;
@property(nonatomic,assign)CGFloat scaleY;
@end
@implementation CKCGAffineTransformWrapper
@synthesize x,y,angle,scaleX,scaleY;
@end

@implementation CKCGAffineTransformPropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[CKCGAffineTransformWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CGAffineTransform transform;
    [[p value]getValue:&transform];
    
	CKCGAffineTransformWrapper* wrapper = (CKCGAffineTransformWrapper*)self.multiFloatValue;

    wrapper.x = CGAffineTransformGetTranslateX(transform);
    wrapper.y = CGAffineTransformGetTranslateY(transform);
    wrapper.angle = CGAffineTransformGetRotation(transform);
    wrapper.scaleX = CGAffineTransformGetScaleX(transform);
    wrapper.scaleY = CGAffineTransformGetScaleY(transform);
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CKCGAffineTransformWrapper* wrapper = (CKCGAffineTransformWrapper*)self.multiFloatValue;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
    CGAffineTransformScale(transform, wrapper.scaleX,wrapper.scaleY);
    CGAffineTransformRotate(transform, wrapper.angle);
    CGAffineTransformTranslate(transform, wrapper.x, wrapper.y);
	[p setValue:[NSValue value:&transform withObjCType:@encode(CGAffineTransform)]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 5 * 44)];
}

@end