//
//  CKCGPropertyCellControllers.m
//  CloudKit
//
//  Created by Sebastien Morel.
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

- (void)propertyChanged{
    CKObjectProperty* p = (CKObjectProperty*)self.value;
	CGSize size = [[p value]CGSizeValue];
	
	CGSizeWrapper* sizeWrapper = (CGSizeWrapper*)self.multiFloatValue;
	sizeWrapper.width = size.width;
	sizeWrapper.height = size.height;
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

- (void)propertyChanged{
    CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CGPoint point = [[p value]CGPointValue];
	
	CGPointWrapper* pointWrapper = (CGPointWrapper*)self.multiFloatValue;
	pointWrapper.x = point.x;
	pointWrapper.y = point.y;
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

- (void)propertyChanged{
    CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CGRect rect = [[p value]CGRectValue];
	
	CGRectWrapper* rectWrapper = (CGRectWrapper*)self.multiFloatValue;
	rectWrapper.x = rect.origin.x;
	rectWrapper.y = rect.origin.y;
	rectWrapper.width = rect.size.width;
	rectWrapper.height = rect.size.height;
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

- (void)propertyChanged{
    CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	UIEdgeInsets insets = [[p value]UIEdgeInsetsValue];
	
	UIEdgeInsetsWrapper* insetsWrapper = (UIEdgeInsetsWrapper*)self.multiFloatValue;
	insetsWrapper.top = insets.top;
	insetsWrapper.left = insets.left;
	insetsWrapper.bottom = insets.bottom;
	insetsWrapper.right = insets.right;

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

- (void)propertyChanged{
    CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CLLocationCoordinate2D coord;
    NSValue* value = [p value];
    if(value){
        [[p value]getValue:&coord];
    }
    
	CLLocationCoordinate2DWrapper* coordWrapper = (CLLocationCoordinate2DWrapper*)self.multiFloatValue;
    coordWrapper.latitude = coord.latitude;
    coordWrapper.longitude = coord.longitude;
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

- (void)propertyChanged{
    CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	CGAffineTransform transform;
    id value = [p value];
    if([value isKindOfClass:[NSValue class]]){
        [value getValue:&transform];
        
        CKCGAffineTransformWrapper* wrapper = (CKCGAffineTransformWrapper*)self.multiFloatValue;
        
        wrapper.x = CKCGAffineTransformGetTranslateX(transform);
        wrapper.y = CKCGAffineTransformGetTranslateY(transform);
        wrapper.angle =  CKCGAffineTransformGetRotation(transform) * 180 / M_PI;
        wrapper.scaleX = CKCGAffineTransformGetScaleX(transform);
        wrapper.scaleY = CKCGAffineTransformGetScaleY(transform);
    }
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CKCGAffineTransformWrapper* wrapper = (CKCGAffineTransformWrapper*)self.multiFloatValue;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, wrapper.scaleX,wrapper.scaleY);
    transform = CGAffineTransformRotate(transform, wrapper.angle * M_PI / 180.0 );
    transform = CGAffineTransformTranslate(transform, wrapper.x, wrapper.y);
	[p setValue:[NSValue value:&transform withObjCType:@encode(CGAffineTransform)]];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 5 * 44)];
}

@end