//
//  CKDownloadManager.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDownloadManager.h"
#import "CKWebRequest.h"

#import "NSObject+JSON.h"
#import "CKDebug.h"

//

NSString *CKDownloadManagerDownloadDidFinishNotification = @"CKDownloadManagerDownloadDidFinishNotification";
NSString *CKDownloadManagerDownloadDidFailNotification = @"CKDownloadManagerDownloadDidFailNotification";

//

@interface CKWebRequest (CKDownloader)

@property (nonatomic, readonly) NSString *downloadName;

@end

@implementation CKWebRequest (CKDownloader)

- (NSString *)downloadName {
    return [[self.downloadPath stringByDeletingPathExtension] lastPathComponent];
}

@end

static CKDownloadManager *CKSharedDownloadManager;

//

@interface CKDownloadManager ()
@property (nonatomic, retain) NSMutableDictionary *downloaders;
@end

//

@implementation CKDownloadManager

@synthesize downloaders;

+ (id)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKSharedDownloadManager = [[CKDownloadManager alloc] init];
    });
    return CKSharedDownloadManager;
}

//

- (id)init {
    self = [super init];
    if (self) {
        self.downloaders = [[[NSMutableDictionary alloc] init] autorelease];
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

- (CKWebRequest *)downloaderForName:(NSString *)name {
    return [self.downloaders objectForKey:name];
}

- (CKWebRequest*)downloadContentOfURL:(NSURL *)URL fileName:(NSString *)name {
    if ([self fileURLForName:name])
        return nil;
    
    if ([self downloaderForName:name])
        return nil;
    
    NSString *filePath = [self filePathForName:name];
    NSString *temporaryFilePath = [self temporaryFilePathForName:name];
    NSString *metadataPath = [self metaFilePathForName:name];
    CKWebRequest *downloader = [CKWebRequest scheduledRequestWithURL:URL parameters:nil downloadAtPath:temporaryFilePath completion:^(id object, NSURLResponse *response, NSError *error) {
        [self downloader:[self downloaderForName:name] didReceiveResponse:(NSHTTPURLResponse*)response];
        
        if (!error) {
            NSError *error = nil;
            [[NSFileManager defaultManager] moveItemAtPath:temporaryFilePath toPath:filePath error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:metadataPath error:&error];
            
            [self downloaderDidFinish:[self downloaderForName:name]];
        }
        else 
            [self downloader:[self downloaderForName:name] didFailWithError:error];
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

- (void)abortDownload:(CKWebRequest*)downloader{
    NSString* path = [downloader.downloadName stringByReplacingOccurrencesOfString:@".inprogress" withString:@""];
    
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
    
    [self.downloaders removeObjectForKey:downloader.downloadName];
}

#pragma CKDownloader Delegate

// NCDownloader Delegate

- (void)downloader:(CKWebRequest *)downloader didReceiveResponse:(NSHTTPURLResponse *)response {
    CKDebugLog(@"didReceiveResponse %d <%lld bytes>", [response statusCode], [response expectedContentLength]);
    
    if ([self metadataExistsForName:downloader.downloadName] == NO) {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        [md setObject:[downloader.URL description] forKey:@"url"];
        [md setObject:[NSString stringWithFormat:@"%lld", [response expectedContentLength]] forKey:@"length"];
        [md setObject:downloader.downloadName forKey:@"filename"];
        [self createMetadataForName:downloader.downloadName content:md];
        return;
    }
}

- (void)downloaderDidFinish:(CKWebRequest *)downloader {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:downloader.downloadName forKey:@"name"];
    [userInfo setObject:downloader.URL forKey:@"url"];
    [userInfo setObject:[self fileURLForName:downloader.downloadName] forKey:@"file"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKDownloadManagerDownloadDidFinishNotification 
                                                        object:self 
                                                      userInfo:userInfo];
    
    [self.downloaders removeObjectForKey:downloader.downloadName];
}

- (void)downloader:(CKWebRequest *)downloader didFailWithError:(NSError *)error {
    CKDebugLog(@"didFailWithError %@", error);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:error forKey:@"error"];
    [userInfo setObject:downloader.downloadName forKey:@"name"];
    [userInfo setObject:downloader.URL forKey:@"url"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKDownloadManagerDownloadDidFailNotification 
                                                        object:self 
                                                      userInfo:userInfo];
    
    [self.downloaders removeObjectForKey:downloader.downloadName];
    
    if ((error.code == NSURLErrorNotConnectedToInternet) || (error.code == NSURLErrorNetworkConnectionLost))
        return;
    
    // Proceed to clean up for other errors.        
    // FIXME: should be put in a function
    
    NSString *temporaryFilePath = [self temporaryFilePathForName:downloader.downloadName];
    NSString *metadataPath = [self metaFilePathForName:downloader.downloadName];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:metadataPath error:nil];
}

@end
