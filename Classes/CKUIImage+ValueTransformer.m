//
//  CKUIImage+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIImage+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSValueTransformer+CGTypes.h"


@implementation UIImage (CKValueTransformer)

+ (UIImage*)convertFromNSString:(NSString*)str{
	UIImage* image = [UIImage imageNamed:str];
	return image;
}

+ (UIImage*)convertFromNSURL:(NSURL*)url{
	if([url isFileURL]){
		UIImage* image = [UIImage imageWithContentsOfFile:[url path]];
		return image;
	}
	NSAssert(NO,@"Styles only supports file url yet");
	return nil;
}

+ (UIImage*)convertFromNSArray:(NSArray*)components{
	NSAssert([components count] == 2,@"invalid format for image");
	NSString* name = [components objectAtIndex:0];
	
	UIImage* image = [UIImage imageNamed:name];
	if(image){
		NSString* sizeStr = [components objectAtIndex:1];
		CGSize size = [NSValueTransformer parseStringToCGSize:sizeStr];
		image = [image stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
		return image;
	}
	return nil;
}

+ (NSString*)convertToNSString:(UIImage*)image{
	return [image description];
}

@end
