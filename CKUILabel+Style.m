//
//  UILabel+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUILabel+Style.h"
#import "CKStyles.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKLocalization.h"

NSString* CKStyleTextColor = @"color";
NSString* CKStyleFontSize = @"fontSize";
NSString* CKStyleFontName = @"fontName";
NSString* CKStyleText = @"text";
NSString* CKStyleNumberOfLines = @"numberOfLines";

@implementation NSDictionary (CKUILabelStyle)

- (UIColor*)textColor{
	id object = [self objectForKey:CKStyleTextColor];
	if([object isKindOfClass:[NSString class]]){
		return [CKStyleParsing parseStringToColor:object];
	}
	NSAssert(object == nil || [object isKindOfClass:[UIColor class]],@"invalid class for textColor");
	return (object == nil) ? [UIColor blackColor] : (UIColor*)object;
}

- (CGFloat)fontSize{
	id object = [self objectForKey:CKStyleFontSize];
	if([object isKindOfClass:[NSString class]]){
		return [object floatValue];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for fontSize");
	return (object == nil) ? 11 : [object floatValue];
}

- (NSString*)fontName{
	id object = [self objectForKey:CKStyleFontName];
	NSAssert(object == nil || [object isKindOfClass:[NSString class]],@"invalid class for fontName");
	return (NSString*)object;
}

- (NSString*)text{
	id object = [self objectForKey:CKStyleText];
	NSAssert(object == nil || [object isKindOfClass:[NSString class]],@"invalid class for text");
	return _((NSString*)object);
}

- (NSInteger)numberOfLines{
	id object = [self objectForKey:CKStyleNumberOfLines];
	if([object isKindOfClass:[NSString class]]){
		return [object intValue];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for numberOfLines");
	return (object == nil) ? 0 : [object intValue];
}

@end

@implementation UILabel (CKStyle)

+ (BOOL)applyStyle:(NSDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	if([UIView applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack]){
		UILabel* label = (UILabel*)view;
		NSDictionary* myLabelStyle = [style styleForObject:label propertyName:propertyName];
		if(myLabelStyle){
			if([myLabelStyle containsObjectForKey:CKStyleTextColor])
				label.textColor = [myLabelStyle textColor];
			if([myLabelStyle containsObjectForKey:CKStyleText])
				label.text = [myLabelStyle text];
			if([myLabelStyle containsObjectForKey:CKStyleNumberOfLines])
				label.numberOfLines = [myLabelStyle numberOfLines];
			
			NSString* fontName = label.font.fontName;
			if([myLabelStyle containsObjectForKey:CKStyleFontName])
				fontName= [myLabelStyle fontName];
			CGFloat fontSize = label.font.pointSize;
			if([myLabelStyle containsObjectForKey:CKStyleFontSize])
				fontSize= [myLabelStyle fontSize];
			label.font = [UIFont fontWithName:fontName size:fontSize];
			return YES;
		}
	}
	return NO;
}

@end
