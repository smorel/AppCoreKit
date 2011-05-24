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

NSString* CKStyleFontSize = @"fontSize";
NSString* CKStyleFontName = @"fontName";

@implementation NSMutableDictionary (CKUILabelStyle)

- (CGFloat)fontSize{
	return [self cgFloatForKey:CKStyleFontSize];
}

- (NSString*)fontName{
	return [self stringForKey:CKStyleFontName];
}

@end

@implementation UILabel (CKValueTransformer)

- (void)textAlignmentMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)lineBreakModeMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UILineBreakModeWordWrap,
											   UILineBreakModeCharacterWrap,
											   UILineBreakModeClip,
											   UILineBreakModeHeadTruncation,
											   UILineBreakModeTailTruncation,
											   UILineBreakModeMiddleTruncation);
}

- (void)baselineAdjustmentMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UIBaselineAdjustmentAlignBaselines,
											   UIBaselineAdjustmentAlignCenters,
											   UIBaselineAdjustmentNone);
}

@end

@implementation UILabel (CKStyle)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleFontName,CKStyleFontSize,nil]];
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UILabel* label = (UILabel*)view;
		NSMutableDictionary* myLabelStyle = style;
		if(myLabelStyle){
			
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

//special case for font as fonts have no property size !