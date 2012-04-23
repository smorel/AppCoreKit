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

@interface CKDownloader : NSObject <CKWebRequestDelegate> {
	__unsafe_unretained id _delegate;
    id _userInfo;
	CKWebRequest *_request;
	NSURL *_URL;
	NSString *_destinationPath;
	
	unsigned long long _byteReceived;
	unsigned long long _expectedLength;
	
	float _progress;
    NSUInteger _retriesCount;
    BOOL _skipResponseData;
    
    CKDownloaderCompletionBlock _completionBlock;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSString *destinationPath;
@property (nonatomic, assign) float progress;
@property (nonatomic, readonly) NSUInteger totalBytesWritten;
@property (nonatomic, readonly) NSUInteger totalExpectedBytes;

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