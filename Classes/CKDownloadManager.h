//
//  CKDownloadManager.h
//  CloudKit
//
//  Created by Fred Brunel on 11-11-23.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *CKDownloadManagerDownloadDidFinishNotification;
extern NSString *CKDownloadManagerDownloadDidFailNotification;

@class CKDownloader;

@interface CKDownloadManager : NSObject

+ (id)sharedManager;

- (CKDownloader *)downloadContentOfURL:(NSURL *)URL fileName:(NSString *)name;
- (CKDownloader *)downloaderForName:(NSString *)name;
- (NSURL *)fileURLForName:(NSString *)name;
- (void)abortDownload:(CKDownloader*)downloader;

- (NSString *)defaultDirectoryPath;
//

- (void)resumeAllDownloads;

@end
