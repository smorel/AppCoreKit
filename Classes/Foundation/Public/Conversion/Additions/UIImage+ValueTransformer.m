//
//  UIImage+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIImage+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"
#import "NSValueTransformer+CGTypes.h"
#import "CKResourceManager.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Transformations.h"

#import "CKResourceDependencyContext.h"

#import "CKDebug.h"

@implementation UIImage (CKValueTransformer)

+ (UIImage*)convertFromNSString:(NSString*)str{
    NSString* imagePath = [CKResourceManager pathForImageNamed:str];
    if(imagePath){
        [CKResourceDependencyContext addDependency:imagePath];
        return [UIImage imageWithContentsOfFile:imagePath];
    }
	return [CKResourceManager imageNamed:str];;
}

+ (UIImage*)convertFromNSURL:(NSURL*)url{
	if([url isFileURL]){
        if([url isFileURL]){
            NSString* imagePath = [url path];
            if(imagePath){
                [CKResourceDependencyContext addDependency:imagePath];
                return  [UIImage imageWithContentsOfFile:imagePath];
            }
        }
        
		UIImage* image = [UIImage imageWithContentsOfFile:[url path]];
		return image;
	}
	CKAssert(NO,@"Styles only supports file url yet");
	return nil;
}

+ (UIImage*)convertFromNSArray:(NSArray*)components{
	CKAssert([components count] == 2,@"invalid format for image");
	NSString* name = [components objectAtIndex:0];
	
    UIImage* image = nil;
    NSString* imagePath = [CKResourceManager pathForImageNamed:name];
    if(imagePath){
        [CKResourceDependencyContext addDependency:imagePath];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }else{
        image = [CKResourceManager imageNamed:name];
    }
    
	if(image){
		NSString* sizeStr = [components objectAtIndex:1];
		CGSize size = [NSValueTransformer parseStringToCGSize:sizeStr];
		image = [image stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
		return image;
	}
	return nil;
}


+ (UIImage*)convertFromNSDictionary:(NSDictionary*)dictionary{
    NSString* name = [dictionary objectForKey:@"name"];
    if(!name)
        return nil;
    
    UIImage* image = nil;
    NSString* imagePath = [CKResourceManager pathForImageNamed:name];
    if(imagePath){
        [CKResourceDependencyContext addDependency:imagePath];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }else{
        image = [CKResourceManager imageNamed:name];
    }
    
    if(!image)
        return nil;

    
    NSString* colorStr = [dictionary objectForKey:@"tintColor"];
    if(colorStr){
        UIColor* tintColor = [NSValueTransformer transform:colorStr toClass:[UIColor class]];
        image = [image tintedImageWithColor:tintColor];
    }
    
    NSString* sizeStr = [dictionary objectForKey:@"resizableInsets"];
    if(sizeStr){
        CGSize size = [NSValueTransformer parseStringToCGSize:sizeStr];
        image = [image stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
    }
    
    return image;
}

+ (NSString*)convertToNSString:(UIImage*)image{
	return [image description];
}

@end
