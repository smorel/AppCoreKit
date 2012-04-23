//
//  CKDownloadManager.m
//  CloudKit
//
//  Created by Fred Brunel on 11-11-23.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDownloadManager.h"
#import "CKDownloader.h"

#import <CloudKit/CKNSObject+JSON.h>
#import <CloudKit/CKDebug.h>

//

NSString *CKDownloadManagerDownloadDidFinishNotification = @"CKDownloadManagerDownloadDidFinishNotification";
NSString *CKDownloadManagerDownloadDidFailNotification = @"CKDownloadManagerDownloadDidFailNotification";

//

static CKDownloadManager *CKSharedDownloadManager;

//

@interface CKDownloadManager ()
@property (nonatomic, retain) NSMutableDictionary *downloaders;
@end

//

@implementation CKDownloadManager

@synthesize downloaders;

+ (id)sharedManager {
    @synchronized(self) {
        if (CKSharedDownloadManager == nil) {
            CKSharedDownloadManager = [[CKDownloadManager alloc] init];
        }
        return CKSharedDownloadManager;
    }
}

//

- (id)init {
    self = [super init];
    if (self) {
        self.downloaders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma File Management

- (NSString *)defaultDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (NSString *)filePathForName:(NSString *)name {
    return [[self defaultDirectoryPath] stringByAppendingPathComponent:name];
}

- (NSString *)temporaryFilePathForName:(NSString *)name {
    return [[self filePathForName:name] stringByAppendingPathExtension:@"inprogress"];
}

- (NSString *)metaFilePathForName:(NSString *)name {
    return [[self filePathForName:name] stringByAppendingPathExtension:@"md"];
}

// Metadata

- (BOOL)metadataExistsForName:(NSString *)name {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self metaFilePathForName:name]];
}

- (BOOL)createMetadataForName:(NSString *)name content:(NSDictionary *)content {
    if ([self metadataExistsForName:name])
        return NO;
    NSData *data = [[content JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    return [data writeToFile:[self metaFilePathForName:name] options:NSDataWritingAtomic error:&error];
}

- (NSDictionary *)readMetadataForName:(NSString *)name {
    NSError *error = nil;
    return [NSObject objectFromJSONData:[NSData dataWithContentsOfFile:[self metaFilePathForName:name]] error:&error];
}

#pragma Public API

- (NSURL *)fileURLForName:(NSString *)name {
    NSString *filePath = [self filePathForName:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (CKDownloader *)downloaderForName:(NSString *)name {
    return [self.downloaders objectForKey:name];
}

- (CKDownloader*)downloadContentOfURL:(NSURL *)URL fileName:(NSString *)name {
    if ([self fileURLForName:name])
        return nil;
    
    if ([self downloaderForName:name])
        return nil;
    
    CKDownloader *downloader = [[CKDownloader alloc] initWithDelegate:self];
    downloader.userInfo = name;
    NSString *filePath = [self filePathForName:name];
    NSString *temporaryFilePath = [self temporaryFilePathForName:name];
    NSString *metadataPath = [self metaFilePathForName:name];
    
    [downloader downloadContentOfURL:URL destination:temporaryFilePath completion:^{
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:temporaryFilePath toPath:filePath error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:metadataPath error:&error];
    }];
    
    [self.downloaders setObject:downloader forKey:name];
    
    return downloader;
}

//

- (void)resumeAllDownloads {
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self defaultDirectoryPath]];
    NSString *filename;
    while (filename = [enumerator nextObject]) {
        if ([[filename pathExtension] isEqualToString:@"md"]) {
            NSError *error = nil;
            NSString *filePath = [[self defaultDirectoryPath] stringByAppendingPathComponent:filename];
            NSDictionary *md = [NSObject objectFromJSONData:[NSData dataWithContentsOfFile:filePath] error:&error];
            NSString *name = [md objectForKey:@"filename"];
            NSURL *URL = [NSURL URLWithString:[md objectForKey:@"url"]];
            [self downloadContentOfURL:URL fileName:name];
        }
    }
}

- (void)abortDownload:(CKDownloader*)downloader{
    NSString* path = [downloader.destinationPath stringByReplacingOccurrencesOfString:@".inprogress" withString:@""];
    
    [downloader cancel];
    NSString* inProgressPath = [NSString stringWithFormat:@"%@.inprogress",path];
    
    if([[NSFileManager defaultManager ]fileExistsAtPath:inProgressPath]){
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:inProgressPath error:&error];
        
        NSAssert(error == nil, @"Could not delete file");
    }
    
    NSString* metaDataPath = [NSString stringWithFormat:@"%@.md",path];
    
    if([[NSFileManager defaultManager ]fileExistsAtPath:metaDataPath]){
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:metaDataPath error:&error];
        
        NSAssert(error == nil, @"Could not delete file");
    }
    
    [self.downloaders removeObjectForKey:downloader.userInfo];
}

#pragma CKDownloader Delegate

// NCDownloader Delegate

- (void)downloader:(CKDownloader *)downloader didReceiveResponse:(NSHTTPURLResponse *)response {
    CKDebugLog(@"didReceiveResponse %d <%lld bytes>", [response statusCode], [response expectedContentLength]);
    
    if ([self metadataExistsForName:downloader.userInfo] == NO) {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        [md setObject:[downloader.URL description] forKey:@"url"];
        [md setObject:[NSString stringWithFormat:@"%lld", [response expectedContentLength]] forKey:@"length"];
        [md setObject:downloader.userInfo forKey:@"filename"];
        [self createMetadataForName:downloader.userInfo content:md];
        return;
    }
}

- (void)downloaderDidFinish:(CKDownloader *)downloader {
    CKDebugLog(@"downloaderDidFinish <%d bytes written; %d expected bytes>", downloader.totalBytesWritten, downloader.totalExpectedBytes);

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:downloader.userInfo forKey:@"name"];
    [userInfo setObject:downloader.URL forKey:@"url"];
    [userInfo setObject:[self fileURLForName:downloader.userInfo] forKey:@"file"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKDownloadManagerDownloadDidFinishNotification 
                                                        object:self 
                                                      userInfo:userInfo];
    
    [self.downloaders removeObjectForKey:downloader.userInfo];
}

- (void)downloader:(CKDownloader *)downloader didFailWithError:(NSError *)error {
    CKDebugLog(@"didFailWithError %@", error);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:error forKey:@"error"];
    [userInfo setObject:downloader.userInfo forKey:@"name"];
    [userInfo setObject:downloader.URL forKey:@"url"];

    [[NSNotificationCenter defaultCenter] postNotificationName:CKDownloadManagerDownloadDidFailNotification 
                                                        object:self 
                                                      userInfo:userInfo];
    
    [self.downloaders removeObjectForKey:downloader.userInfo];

    if ((error.code == NSURLErrorNotConnectedToInternet) || (error.code == NSURLErrorNetworkConnectionLost))
        return;

    // Proceed to clean up for other errors.        
    // FIXME: should be put in a function

    NSString *temporaryFilePath = [self temporaryFilePathForName:downloader.userInfo];
    NSString *metadataPath = [self metaFilePathForName:downloader.userInfo];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:metadataPath error:nil];
}

- (void)downloader:(CKDownloader *)downloader didReceiveDataOfLength:(NSUInteger)length totalBytesWritten:(NSUInteger)totalBytesWritten totalBytesExpectedToWrite:(NSUInteger)totalBytesExpectedToWrite {
    CKDebugLog(@"recv [%d%%] <%d bytes; %d bytes written; %d expected bytes>", (int)(downloader.progress * 100), length, totalBytesWritten, totalBytesExpectedToWrite);
}

@end
