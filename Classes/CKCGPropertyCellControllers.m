//
//  CKCGPropertyCellControllers.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCGPropertyCellControllers.h"
#import "CKObjectProperty.h"

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
	return [NSValue valueWithCGSize:CGSizeMake(100,50 + 2 * 44)];
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
	return [NSValue valueWithCGSize:CGSizeMake(100,50 + 2 * 44)];
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
	return [NSValue valueWithCGSize:CGSizeMake(100,50 + 4 * 44)];
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
	
	CLLocationCoordinate2D* coord = (CLLocationCoordinate2D*)[[p value]objCType];
	
	CLLocationCoordinate2DWrapper* coordWrapper = (CLLocationCoordinate2DWrapper*)self.multiFloatValue;
	coordWrapper.latitude = coord->latitude;
	coordWrapper.longitude = coord->longitude;
	
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
	return [NSValue valueWithCGSize:CGSizeMake(100,50 + 2 * 44)];
}

@end



/*

//SEE LATER
@implementation CKCGAffineTransformPropertyCellController

- (id)init{
	[super init];
	return self;
}

- (void)valueChanged{
	//todo
}

@end
*/