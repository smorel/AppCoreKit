//
//  CKDownloader.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKWebRequest2.h"

extern NSString * const CKDownloaderErrorDomain;

@interface CKDownloader  : NSObject <CKWebRequestDelegate,NSCopying> {
	id _delegate;
	CKWebRequest2 *_request;
	NSURL *_remoteURL;
	NSURL *_localURL;
	
	NSNumber* _progress;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSURL *remoteURL;
@property (nonatomic, retain) NSURL *localURL;
@property (nonatomic, retain) NSNumber *progress;

- (id)initWithDelegate:(id)delegate;
- (void)downloadContentOfURL:(NSURL *)url toLocalURL:(NSURL*)local;
- (void)cancel;
- (void)retry;

@end


@protocol CKDownloaderDelegate

- (void)downloader:(CKDownloader *)downloader didDownloadContent:(NSData *)content;
- (void)downloader:(CKDownloader *)downloader didFailWithError:(NSError *)error;
- (void)downloader:(CKDownloader *)downloader progress:(NSNumber *)normalizedProgress;

@end