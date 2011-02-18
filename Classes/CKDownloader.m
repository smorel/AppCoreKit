//
//  CKDownloader.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDownloader.h"

#import "CKCache.h"
#import "CKLocalization.h"

NSString * const CKDownloaderErrorDomain = @"CKDownloaderErrorDomain";

@interface CKDownloader ()
@property (nonatomic, retain) CKWebRequest2 *request;
@end

@implementation CKDownloader

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize remoteURL = _remoteURL;
@synthesize localURL = _localURL;
@synthesize progress = _progress;

- (id)initWithDelegate:(id)delegate {
	if (self = [super init]) {
		self.delegate = delegate;
		//self.imageSize = CGSizeZero;
	}
	return self;
}

- (void)dealloc {
	[self cancel];
	self.remoteURL = nil;
	self.localURL = nil;
	self.progress = nil;
	[super dealloc];
}

//Shallow copy to allow downloader as key in dictionaries for example.
- (id)copyWithZone:(NSZone *)zone{
	return [self retain];
}

#pragma mark Public API

- (void)downloadContentOfURL:(NSURL *)url toLocalURL:(NSURL*)local{
	[self cancel];
	
	NSAssert([local isFileURL],@"%@ : Try to donwload %@ to %@ wich is not a file URL.",CKDownloaderErrorDomain,url,local);
	self.remoteURL = url;
	self.localURL = local;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[local path]] ){
		NSData * content = [[NSFileManager defaultManager] contentsAtPath:[local path]];
		[self.delegate downloader:self didDownloadContent:content];
	}
	else{
		self.request = [CKWebRequest2 requestWithURL:self.remoteURL];
		//self.request init with local url for direct to disk access.
		self.request.delegate = self;
		[self.request start];
	}
}

- (void)cancel {
	self.request.delegate = nil;
	[self.request cancel];
	self.request = nil;
}

#pragma mark CKWebRequestDelegate Protocol

- (void)request:(id)request didReceiveValue:(id)value {
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:didDownloadContent:)]) {
		[self.delegate downloader:self didDownloadContent:(NSData*)value];
	}
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:didFailWithError:)]){
		[self.delegate downloader:self didFailWithError:error];
	}
}

- (void)request:(id)request progress:(NSNumber*)normalizedProgress{
	self.progress = normalizedProgress;
	if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:progress:)]) {
		[self.delegate downloader:self progress:normalizedProgress];
	}
}

@end
