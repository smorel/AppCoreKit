//
//  CKNSDictionary+TableView.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSDictionary+TableViewAttributes.h"

NSString* const CKTableViewAttributeBounds = @"CKTableViewAttributeBounds";
NSString* const CKTableViewAttributePagingEnabled = @"CKTableViewAttributePagingEnabled";
NSString* const CKTableViewAttributeInterfaceOrientation = @"CKTableViewAttributeInterfaceOrientation";
NSString* const CKTableViewAttributeOrientation = @"CKTableViewAttributeOrientation";
NSString* const CKTableViewAttributeAnimationDuration = @"CKTableViewAttributeAnimationDuration";
NSString* const CKTableViewAttributeEditable = @"CKTableViewAttributeEditable";
NSString* const CKTableViewAttributeStyle = @"CKTableViewAttributeStyle";
NSString* const CKTableViewAttributeParentController = @"CKTableViewAttributeParentController";
NSString* const CKTableViewAttributeObject = @"CKTableViewAttributeObject";
NSString* const CKTableViewAttributeStaticController = @"CKTableViewAttributeStaticController";
NSString* const CKTableViewAttributeStaticControllerStyle = @"CKTableViewAttributeStaticControllerStyle";

@implementation NSDictionary (CKTableViewAttributes)

- (BOOL)pagingEnabled{
	NSNumber* v = (NSNumber*)[self objectForKey:CKTableViewAttributePagingEnabled];
	return v ? [v boolValue] : NO;
}

- (UIInterfaceOrientation)interfaceOrientation{
	NSNumber* v = (NSNumber*)[self objectForKey:CKTableViewAttributeInterfaceOrientation];
	return (UIInterfaceOrientation)v ? [v intValue] : UIInterfaceOrientationPortrait;
}

- (CGSize)bounds{
	NSValue* v = (NSValue*)[self objectForKey:CKTableViewAttributeBounds];
	return v ? [v CGSizeValue] : CGSizeMake(0, 0);
}

- (CKTableViewOrientation)tableOrientation{
	NSNumber* v = (NSNumber*)[self objectForKey:CKTableViewAttributeOrientation];
	return (CKTableViewOrientation)v ? [v intValue] : CKTableViewOrientationPortrait;
}

- (NSTimeInterval)animationDuration{
	NSNumber* v = (NSNumber*)[self objectForKey:CKTableViewAttributeAnimationDuration];
	return (NSTimeInterval) (v ? [v doubleValue] : 0.0);
}

- (BOOL)editable{
	NSNumber* v = (NSNumber*)[self objectForKey:CKTableViewAttributeEditable];
	return v ? [v boolValue] : NO;
}

- (id)style{
	return [self objectForKey:CKTableViewAttributeStyle];
}

- (UIViewController*)parentController{
	NSValue* value = [self objectForKey:CKTableViewAttributeParentController];
	return (UIViewController*)[value nonretainedObjectValue];
}

- (id)object{
	return [self objectForKey:CKTableViewAttributeObject];
}

- (NSMutableDictionary*)staticControllerStyle{
	return [self objectForKey:CKTableViewAttributeStaticControllerStyle];
}

- (CKItemViewController*)staticController{
	return [self objectForKey:CKTableViewAttributeStaticController];
}

@end
