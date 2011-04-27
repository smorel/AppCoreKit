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

NSString* CKStyleTextColor = @"textcolor";
NSString* CKStyleFontSize = @"fontSize";
NSString* CKStyleFontName = @"fontName";
NSString* CKStyleText = @"text";
NSString* CKStyleNumberOfLines = @"numberOfLines";

@implementation NSMutableDictionary (CKUILabelStyle)

- (UIColor*)textColor{
	return [self colorForKey:CKStyleTextColor];
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

@end

@implementation UILabel (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
	if([UIView applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack delegate:delegate]){
		UILabel* label = (UILabel*)view;
		NSMutableDictionary* myLabelStyle = [style styleForObject:label propertyName:propertyName];
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
