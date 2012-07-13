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
#import "CKLiveProjectFileUpdateManager.h"
#import "CKLocalizationManager.h"
#import "CKCascadingTree.h"
#import "CKLocalizationManager_Private.h"


@implementation UIImage (CKValueTransformer)

#if TARGET_IPHONE_SIMULATOR
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+(UIImage *)imageNamed:(NSString *)name {
    if ([[UIScreen mainScreen] scale] == 2) {
        if (![[name pathExtension] isEqualToString:@""]) {
            NSString *pathExtension = [name pathExtension];
            name = [[[name stringByDeletingPathExtension] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:pathExtension];
        }
        else
            name = [name stringByAppendingString:@"@2x"];
    }
    
    
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:[name pathExtension]];
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:@"png"];
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:nil];
    
    if (imageURL == nil)
        return nil;
    
    UIImage *image = [[[UIImage alloc] initWithContentsOfFile:imageURL.path] autorelease];
    return image;
}

- (id)initWithContentsOfFile:(NSString *)path {
    if (path.length == 0)
        return nil;
    
    NSString *localPath = [[CKLiveProjectFileUpdateManager sharedInstance] projectPathOfFileToWatch:path handleUpdate:^(NSString *localPath) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CKCascadingTreeFilesDidUpdateNotification object:self];
        [[CKLocalizationManager sharedManager] refreshUI];
    }];
    
    CGDataProviderRef ref = CGDataProviderCreateWithCFData((CFDataRef) [NSData dataWithContentsOfFile:localPath]);
    
    CGImageRef imageRef = nil;
    if ([[path pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        imageRef = CGImageCreateWithPNGDataProvider(ref, NULL, NO, kCGRenderingIntentDefault);
    }
    else if ([[path pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        imageRef = CGImageCreateWithJPEGDataProvider(ref, NULL, NO, kCGRenderingIntentDefault);
    }
    
    CGFloat scale = 1;
    if ([[UIScreen mainScreen] scale] == 2) {
        if ([[path lastPathComponent] rangeOfString:@"@2x"].location != NSNotFound)
            scale = 2;
    }
    
    UIImage * anImage = [self initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(ref);
    
    return anImage;
}
#pragma clang diagnostic pop
#endif

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
