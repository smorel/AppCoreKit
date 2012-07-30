//
//  CKLiveUpdateManager.m
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLiveProjectFileUpdateManager.h"
#import <UIKit/UIKit.h>

#import "CKLiveProjectFileUpdateManager.h"
#import "CKLocalization.h"
#import "CKLocalizationManager.h"
#import "CKCascadingTree.h"
#import "CKLocalizationManager_Private.h"

#import "NSObject+Singleton.h"
#import <objc/runtime.h>

#import "CKDebug.h"

#if TARGET_IPHONE_SIMULATOR

static char UIImageImageNameKey;

@interface UIImage(CKLiveProjectFileUpdateManager)
@property(nonatomic,copy) NSString* imageName;
@end

@implementation UIImage(CKLiveProjectFileUpdateManager)

- (void)setImageName:(NSString *)name{
    objc_setAssociatedObject(self, 
                             &UIImageImageNameKey,
                             name,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)imageName{
    return objc_getAssociatedObject(self, &UIImageImageNameKey);
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+(UIImage *)imageNamed:(NSString *)name {
    UIImage* image =  _img(name);
    if(image) image.imageName = name;
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

@end

@interface CKLiveProjectFileUpdateManager ()

@property (retain) NSMutableDictionary*handles;
@property (retain) NSMutableDictionary*projectPaths;
@property (retain) NSMutableDictionary*modificationDate;

@end

@implementation CKLiveProjectFileUpdateManager
@synthesize handles,projectPaths,modificationDate;

- (id)init {
    if (self = [super init]) {
        self.handles = [NSMutableDictionary dictionary];
        self.projectPaths = [NSMutableDictionary dictionary];
        self.modificationDate = [NSMutableDictionary dictionary];
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkForUpdate) userInfo:nil repeats:YES];
    }
    return self;
}

- (NSString*)projectPathOfFileToWatch:(NSString *)path handleUpdate:(void (^)(NSString* localPath))updateHandle {
    NSString *localPath = [self.projectPaths objectForKey:path];
    
    if (!localPath) {
        localPath = [self localPathForResourcePath:path];
        if(localPath){
            [self.handles setObject:[[updateHandle copy] autorelease] forKey:path];
            
            [self.projectPaths setObject:localPath forKey:path];
            [self.modificationDate setObject:[self modificationDateForFileAtPath:localPath] forKey:path];
        }
    }
    
    return localPath ? localPath : path;
}

- (NSString*)localPathForResourcePath:(NSString*)resourcePath {
    NSString* sourcePath = [[[NSProcessInfo processInfo] environment] objectForKey:@"SRC_ROOT"];
    
    if (sourcePath == nil)
        return resourcePath;
    
    NSString *fileName = [resourcePath lastPathComponent];
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:sourcePath];
    
    for (NSString *file in enumerator) {
        if ([[file lastPathComponent] isEqualToString:fileName]) {
            if ([[[resourcePath stringByDeletingLastPathComponent] pathExtension] isEqualToString:@"lproj"]) {
                if ([[[file stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:[[resourcePath stringByDeletingLastPathComponent] lastPathComponent]]) {
                    return [sourcePath stringByAppendingPathComponent:file];
                }
            }
            else
                return [sourcePath stringByAppendingPathComponent:file];
        }
    }
    
    return nil;
}

- (NSDate*)modificationDateForFileAtPath:(NSString*)path {
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSDate* date = [fileAttributes fileModificationDate];
    return date ? date : [NSDate dateWithTimeIntervalSince1970:0];
}

- (void)checkForUpdate {
    NSDictionary* pathsCopy = [self.projectPaths copy];
    
    [pathsCopy enumerateKeysAndObjectsUsingBlock:^(NSString *resourcePath, NSString *localPath, BOOL *stop) {
        NSDate *oldModificationDate = [self.modificationDate objectForKey:resourcePath];
        NSDate *newModificationDate = [self modificationDateForFileAtPath:localPath];
        if (![newModificationDate isEqualToDate:oldModificationDate] && newModificationDate != nil) {
            NSLog(@"Update File : %@", localPath);
            
            [self.modificationDate setObject:newModificationDate forKey:resourcePath];
            
            void (^handleBlock)(NSString* localPath) = [self.handles objectForKey:resourcePath];
            if (handleBlock)
                handleBlock(localPath);
        }
    }];
    
    [pathsCopy release];
}

@end
#endif
