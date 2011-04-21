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


@implementation UIImageView (CKStyle)

+ (BOOL)applyStyle:(NSDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	if([UIView applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack]){
		UIImageView* imageView = (UIImageView*)view;
		NSDictionary* myImageViewStyle = [style styleForObject:imageView propertyName:propertyName];
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
