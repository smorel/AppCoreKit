//
//  CKUIColorPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIColorPropertyCellController.h"
#import "CKUIColorAdditions.h"
#import "CKObjectProperty.h"

@interface CGUIColorWrapper : NSObject{}
@property(nonatomic,assign)CGFloat a;
@property(nonatomic,assign)CGFloat r;
@property(nonatomic,assign)CGFloat g;
@property(nonatomic,assign)CGFloat b;
@end
@implementation CGUIColorWrapper
@synthesize a,r,g,b;
@end

@implementation CKUIColorPropertyCellController

- (id)init{
	[super init];
	self.multiFloatValue = [[[CGUIColorWrapper alloc]init]autorelease];
	return self;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	
	UIColor* color = [p value];
	
	if(color){
		const CGFloat* components = CGColorGetComponents(color.CGColor);
	
		CGUIColorWrapper* colorWrapper = (CGUIColorWrapper*)self.multiFloatValue;
		colorWrapper.r = components[0];
		colorWrapper.g = components[1];
		colorWrapper.b = components[2];
		colorWrapper.a = CGColorGetAlpha(color.CGColor);
	}
	
	[super setupCell:cell];
}

- (void)valueChanged{
	CKObjectProperty* p = (CKObjectProperty*)self.value;
	CGUIColorWrapper* colorWrapper = (CGUIColorWrapper*)self.multiFloatValue;
	
	UIColor* color = [UIColor colorWithRed:colorWrapper.r
					green:colorWrapper.g
					 blue:colorWrapper.b
					alpha:colorWrapper.a];
	[p setValue:color];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44 + 4 * 44)];
}

@end

