//
//  CKDownloader.h
//  CloudKit
//
//  Created by Sebastien Morel, Fred Brunel on 11-02-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKWebRequest.h"

extern NSString * const CKDownloaderErrorDomain;

typedef void (^CKDownloaderCompletionBlock)(void);

@interface CKDownloader : CKWebRequest


- (id)initWithDelegate:(id)delegate;
- (void)downloadContentOfURL:(NSURL *)URL destination:(NSString *)destination completion:(CKDownloaderCompletionBlock)completion;
- (void)cancel;

@end

//

@protocol CKDownloaderDelegate

- (void)downloader:(CKDownloader *)downloader didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)downloaderDidFinish:(CKDownloader *)downloader;
- (void)downloader:(CKDownloader *)downloader didFailWithError:(NSError *)error;
- (void)downloader:(CKDownloader *)downloader didReceiveDataOfLength:(NSUInteger)length totalBytesWritten:(NSUInteger)totalBytesWritten totalBytesExpectedToWrite:(NSUInteger)totalBytesExpectedToWrite;

@end