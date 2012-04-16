//
//  CKUIColorPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIColorPropertyCellController.h"
#import "CKUIColorAdditions.h"
#import "CKProperty.h"
#import "CKNSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>

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

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[CGUIColorWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 4 * 44);
}

- (void)initTableViewCell:(UITableViewCell *)cell {
    [super initTableViewCell:cell];
    
	CKProperty* p = (CKProperty*)self.value;
	UIColor* color = [p value];
    
    UIView* colorView = [[[UIView alloc]initWithFrame:CGRectMake(10,80,80,80)]autorelease];
    colorView.backgroundColor = color;
    colorView.layer.borderColor = [[UIColor blackColor]CGColor];
    colorView.layer.borderWidth = 2;
    colorView.tag = 78;
    
    [cell.contentView addSubview:colorView];
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.value;
	
	UIColor* color = [p value];
	
	if(color){
		const CGFloat* components = CGColorGetComponents(color.CGColor);
        
		CGUIColorWrapper* colorWrapper = (CGUIColorWrapper*)self.multiFloatValue;
		colorWrapper.r = components[0];
		colorWrapper.g = components[1];
		colorWrapper.b = components[2];
		colorWrapper.a = CGColorGetAlpha(color.CGColor);
	}
    
    UIView* colorView = [self.tableViewCell.contentView viewWithTag:78];
    colorView.backgroundColor = color;
}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.value;
	CGUIColorWrapper* colorWrapper = (CGUIColorWrapper*)self.multiFloatValue;
	
	UIColor* color = [UIColor colorWithRed:colorWrapper.r
					green:colorWrapper.g
					 blue:colorWrapper.b
					alpha:colorWrapper.a];
	[p setValue:color];
    
    UIView* colorView = [self.tableViewCell.contentView viewWithTag:78];
    colorView.backgroundColor = color;
}

@end

