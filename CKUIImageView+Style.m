//
//  CKUIImage+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIImageView+Style.h"
#import "CKStyles.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"

NSString* CKStyleImage = @"image";

@implementation NSMutableDictionary (CKUIImageViewStyle)

- (UIImage*)image{
	return [self imageForKey:CKStyleImage];
}

@end

@implementation UIImageView (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UIImageView* imageView = (UIImageView*)view;
		NSMutableDictionary* myImageViewStyle = style;
		if(myImageViewStyle){
			if([myImageViewStyle containsObjectForKey:CKStyleImage])
				imageView.image = [myImageViewStyle image];
			return YES;
		}
		return YES;
	}
	return NO;
}

@end
