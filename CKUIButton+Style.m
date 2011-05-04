//
//  CKUIButton+Style.m
//  CloudKit
//
//  Created by Olivier Collet on 11-04-29.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIButton+Style.h"
#import "CKStyles.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"


NSString *CKStyleDefaultBackgroundImage = @"defaultBackgroundImage";
NSString *CKStyleDefaultImage = @"defaultImage";
NSString *CKStyleDefaultTextColor = @"defaultTextColor";

@implementation NSMutableDictionary (CKUIButtonStyle)

- (UIImage*)defaultBackgroundImage {
	return [self imageForKey:CKStyleDefaultBackgroundImage];
}

- (UIImage*)defaultImage {
	return [self imageForKey:CKStyleDefaultImage];
}

- (UIColor *)defaultTextColor {
	return [self colorForKey:CKStyleDefaultTextColor];
}

@end

//

@implementation UIButton (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack delegate:delegate]){
		UIButton* button = (UIButton *)view;
		NSMutableDictionary* myButtonStyle = [style styleForObject:button propertyName:propertyName];
		if(myButtonStyle){
			if ([myButtonStyle containsObjectForKey:CKStyleDefaultBackgroundImage]) [button setBackgroundImage:[myButtonStyle defaultBackgroundImage] forState:UIControlStateNormal];
			if ([myButtonStyle containsObjectForKey:CKStyleDefaultImage]) [button setImage:[myButtonStyle defaultImage] forState:UIControlStateNormal];
			if ([myButtonStyle containsObjectForKey:CKStyleDefaultTextColor]) [button setTitleColor:[myButtonStyle defaultTextColor] forState:UIControlStateNormal];
			if ([myButtonStyle containsObjectForKey:CKStyleFontSize]) [button.titleLabel setFont:[UIFont boldSystemFontOfSize:[myButtonStyle fontSize]]];
			return YES;
		}
		return YES;
	}
	return NO;
}

@end
