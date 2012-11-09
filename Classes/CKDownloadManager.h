//
//  CKDownloadManager.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CKWebRequest;

/**
 */
extern NSString *CKDownloadManagerDownloadDidFinishNotification;

/**
 */
extern NSString *CKDownloadManagerDownloadDidFailNotification;

@class CKDownloader;


/**
 */
@interface CKDownloadManager : NSObject

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (id)sharedManager;

///-----------------------------------
/// @name Executing download operations
///-----------------------------------

/**
 */
- (CKWebRequest *)downloadContentOfURL:(NSURL *)URL fileName:(NSString *)name;

/**
 */
- (void)resumeAllDownloads;


///-----------------------------------
/// @name Cancelling download operations
///-----------------------------------

/**
 */
- (void)abortDownload:(CKWebRequest*)downloader;


///-----------------------------------
/// @name Accessing download Attributes
///-----------------------------------

/**
 */
- (CKWebRequest *)downloaderForName:(NSString *)name;

/**
 */
- (NSURL *)fileURLForName:(NSString *)name;

/**
 */
- (NSString *)defaultDirectoryPath;

@end
