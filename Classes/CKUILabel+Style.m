//
//  UILabel+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUILabel+Style.h"
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

@implementation UILabel (CKStyle)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
    [super updateReservedKeyWords:keyWords];
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleFontName,CKStyleFontSize,nil]];
}
    
+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UILabel* label = (UILabel*)view;
		NSMutableDictionary* myLabelStyle = style;
		if(myLabelStyle){
			
            CGFloat styleFontSize = [myLabelStyle fontSize];
			CGFloat fontSize = styleFontSize ? styleFontSize : label.font.pointSize;
            
            NSString* styleFontName = [myLabelStyle objectForKey:CKStyleFontName];
            if (styleFontName)
                label.font = [UIFont fontWithName:styleFontName size:fontSize];
            else
                label.font = [label.font fontWithSize:fontSize];
			
			return YES;
		}
	}
	return NO;
}

@end

@implementation UITextField (CKStyle)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
    [super updateReservedKeyWords:keyWords];
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleFontName,CKStyleFontSize,nil]];
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UITextField* txtField = (UITextField*)view;
		NSMutableDictionary* myLabelStyle = style;
		if(myLabelStyle){
			
			NSString* fontName = txtField.font.fontName;
			if([myLabelStyle containsObjectForKey:CKStyleFontName])
				fontName= [myLabelStyle fontName];
			CGFloat fontSize = txtField.font.pointSize;
			if([myLabelStyle containsObjectForKey:CKStyleFontSize])
				fontSize= [myLabelStyle fontSize];
			txtField.font = [UIFont fontWithName:fontName size:fontSize];
            
            
			if([myLabelStyle containsObjectForKey:@"borderStyle"]){
                //As it is a keyword for background windows ... we should apply it manually here
                txtField.borderStyle = [myLabelStyle enumValueForKey:@"borderStyle" 
                   withEnumDescriptor:CKEnumDefinition(@"UITextBorderStyle",
                                                       UITextBorderStyleNone,
                                                       UITextBorderStyleLine,
                                                       UITextBorderStyleBezel,
                                                       UITextBorderStyleRoundedRect
                                                       )];
            }
			
			return YES;
		}
	}
	return NO;
}

@end

//special case for font as fonts have no property size !