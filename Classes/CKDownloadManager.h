//
//  CKDownloadManager.h
//  CloudKit
//
//  Created by Fred Brunel on 11-11-23.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CKWebRequest;

extern NSString *CKDownloadManagerDownloadDidFinishNotification;
extern NSString *CKDownloadManagerDownloadDidFailNotification;

@class CKDownloader;

@interface CKDownloadManager : NSObject

+ (id)sharedManager;

- (CKWebRequest *)downloadContentOfURL:(NSURL *)URL fileName:(NSString *)name;
- (CKWebRequest *)downloaderForName:(NSString *)name;
- (NSURL *)fileURLForName:(NSString *)name;
- (void)abortDownload:(CKWebRequest*)downloader;

- (NSString *)defaultDirectoryPath;
//

- (void)resumeAllDownloads;

@end
