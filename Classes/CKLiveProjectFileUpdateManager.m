//
//  CKLiveUpdateManager.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-08.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLiveProjectFileUpdateManager.h"

#if TARGET_IPHONE_SIMULATOR
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
        [self.handles setObject:[[updateHandle copy] autorelease] forKey:path];
        
        localPath = [self localPathForResourcePath:path];
        [self.projectPaths setObject:localPath forKey:path];
        [self.modificationDate setObject:[self modificationDateForFileAtPath:localPath] forKey:path];
    }
    
    return localPath;
}

- (NSString*)localPathForResourcePath:(NSString*)resourcePath {
    NSString* sourcePath = [[[NSProcessInfo processInfo] environment] objectForKey:@"SRC_ROOT"];
    
    if (sourcePath == nil)
        return [NSURL fileURLWithPath:resourcePath];
    
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
    
    return resourcePath;
}

- (NSDate*)modificationDateForFileAtPath:(NSString*)path {
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileAttributes fileModificationDate];
}

- (void)checkForUpdate {
    [self.projectPaths enumerateKeysAndObjectsUsingBlock:^(NSString *resourcePath, NSString *localPath, BOOL *stop) {
        NSDate *oldModificationDate = [self.modificationDate objectForKey:resourcePath];
        if (![[self modificationDateForFileAtPath:localPath] isEqualToDate:oldModificationDate]) {
            NSLog(@"Update File : %@", localPath);
            
            [self.modificationDate setObject:[self modificationDateForFileAtPath:localPath] forKey:resourcePath];
            
            void (^handleBlock)(NSString* localPath) = [self.handles objectForKey:resourcePath];
            if (handleBlock)
                handleBlock(localPath);
        }
    }];
}

@end
#endif
