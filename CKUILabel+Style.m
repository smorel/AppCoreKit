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

NSString* CKStyleTextColor = @"textColor";
NSString* CKStyleHighlightedTextColor = @"highlightedTextColor";
NSString* CKStyleFontSize = @"fontSize";
NSString* CKStyleFontName = @"fontName";
NSString* CKStyleText = @"text";
NSString* CKStyleNumberOfLines = @"numberOfLines";
NSString* CKStyleShadowColor = @"shadowColor";
NSString* CKStyleShadowOffset = @"shadowOffset";
NSString* CKStyleTextAlignment = @"textAlignment";

@implementation NSMutableDictionary (CKUILabelStyle)

- (UIColor*)textColor{
	return [self colorForKey:CKStyleTextColor];
}

- (UIColor*)highlightedTextColor {
	return [self colorForKey:CKStyleHighlightedTextColor];
}

- (CGFloat)fontSize{
	return [self cgFloatForKey:CKStyleFontSize];
}

- (NSString*)fontName{
	return [self stringForKey:CKStyleFontName];
	
}

- (NSString*)text{
	return _([self stringForKey:CKStyleText]);
}

- (NSInteger)numberOfLines{
	return [self integerForKey:CKStyleNumberOfLines];
}

- (UIColor *)shadowColor {
	return [self colorForKey:CKStyleShadowColor];
}

- (CGSize)shadowOffset {
	return [self cgSizeForKey:CKStyleShadowOffset];
}

- (UITextAlignment)textAlignment{
	return (UITextAlignment)[self enumValueForKey:CKStyleTextAlignment 
								   withDictionary:CKEnumDictionary(UITextAlignmentLeft,
																   UITextAlignmentCenter,
																   UITextAlignmentRight)];
}

@end

@implementation UILabel (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
	if([UIView applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack delegate:delegate]){
		UILabel* label = (UILabel*)view;
		NSMutableDictionary* myLabelStyle = [style styleForObject:label propertyName:propertyName];
		if(myLabelStyle){
			if([myLabelStyle containsObjectForKey:CKStyleTextColor])
				label.textColor = [myLabelStyle textColor];
			if([myLabelStyle containsObjectForKey:CKStyleHighlightedTextColor])
				label.highlightedTextColor = [myLabelStyle highlightedTextColor];
			if([myLabelStyle containsObjectForKey:CKStyleText]){
				if(label.text == nil){
					label.text = [myLabelStyle text];
				}
			}
			if([myLabelStyle containsObjectForKey:CKStyleNumberOfLines])
				label.numberOfLines = [myLabelStyle numberOfLines];
			
			NSString* fontName = label.font.fontName;
			if([myLabelStyle containsObjectForKey:CKStyleFontName])
				fontName= [myLabelStyle fontName];
			CGFloat fontSize = label.font.pointSize;
			if([myLabelStyle containsObjectForKey:CKStyleFontSize])
				fontSize= [myLabelStyle fontSize];
			label.font = [UIFont fontWithName:fontName size:fontSize];

			// Shadow
			if ([myLabelStyle containsObjectForKey:CKStyleShadowColor]) label.shadowColor = [myLabelStyle shadowColor];
			if ([myLabelStyle containsObjectForKey:CKStyleShadowOffset]) label.shadowOffset = [myLabelStyle shadowOffset];
			
			if([myLabelStyle containsObjectForKey:CKStyleTextAlignment])
				label.textAlignment = [myLabelStyle textAlignment];

			return YES;
		}
	}
	return NO;
}

@end
