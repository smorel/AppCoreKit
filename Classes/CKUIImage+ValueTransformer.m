//
//  CKUIImage+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIImage+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSValueTransformer+CGTypes.h"
#import "CKLiveProjectFileUpdateManager.h"
#import <CloudKit/CKLocalizationManager.h>
#import "CKCascadingTree.h"


@implementation UIImage (CKValueTransformer)

#if TARGET_IPHONE_SIMULATOR
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+(UIImage *)imageNamed:(NSString *)name {
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:[name pathExtension]];
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:@"png"];
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:nil];
    
    if (imageURL == nil)
        return nil;
    
    return [[[UIImage alloc] initWithContentsOfFile:imageURL.path] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)path {
    if (path.length == 0)
        return nil;
    
    NSString *localPath = [[CKLiveProjectFileUpdateManager sharedInstance] projectPathOfFileToWatch:path handleUpdate:^(NSString *localPath) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CKCascadingTreeFilesDidUpdateNotification object:self];
        [[CKLocalizationManager sharedManager] refreshUI];
    }];
    
    return [self initWithData:[NSData dataWithContentsOfFile:localPath]];
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
