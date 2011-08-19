//
//  CKUIButton+Style.m
//  CloudKit
//
//  Created by Olivier Collet on 11-04-29.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIButton+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKUILabel+Style.h"


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

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleDefaultBackgroundImage,CKStyleDefaultImage,CKStyleDefaultTextColor,nil]];
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UIButton* button = (UIButton *)view;
		NSMutableDictionary* myButtonStyle = style;
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
