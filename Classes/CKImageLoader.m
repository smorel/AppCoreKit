//
//  CKImageLoader.m
//  CloudKit
//
//  Created by Olivier Collet on 10-07-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageLoader.h"
#import "CKUIImage+Transformations.h"
#import "CKCache.h"
#import "CKLocalization.h"

@interface CKImageLoader ()

@property (nonatomic, retain) CKWebRequest2 *request;

+ (UIImage *)getCachedImageForURL : (NSURL*)url ;

@end

//

@implementation CKImageLoader

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize imageURL = _imageURL;

@synthesize imageSize;
@synthesize aspectFill;

- (id)initWithDelegate:(id)delegate {
	if (self = [super init]) {
		self.delegate = delegate;
		self.imageSize = CGSizeZero;
	}
	return self;
}

- (void)dealloc {
	[self cancel];
	self.imageURL = nil;
	[super dealloc];
}

#pragma mark Caching

+ (UIImage *)getCachedImageForURL : (NSURL*)url {
	NSURLRequest *request = [CKWebRequest2 createRequestForURL:url];
	NSCachedURLResponse * cacheResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	if(cacheResponse){
		return [UIImage imageWithData:cacheResponse.data];
	}
	return nil;
}

#pragma mark Public API

- (void)loadImageWithContentOfURL:(NSURL *)url {
	[self cancel];
	self.imageURL = url;
	
	UIImage *image = [CKImageLoader getCachedImageForURL:url];
	if (image) {
		[self.delegate imageLoader:self didLoadImage:image cached:YES];
	}
	else{
		self.request = [CKWebRequest2 requestWithURL:self.imageURL];
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
	if ([value isKindOfClass:[UIImage class]]) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didLoadImage:cached:)]) {
			[self.delegate imageLoader:self didLoadImage:(UIImage*)value cached:NO];
		}
	}
	else{
		// Throws an error if the value is not an image
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_(@"Did not receive an image") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:@"CKImageLoaderDomain" code:0 userInfo:userInfo];
		[self.delegate imageLoader:self didFailWithError:error];
	}
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	[self.delegate imageLoader:self didFailWithError:error];
}

@end


@implementation CKImageLoader(Deprecated)

+ (UIImage *)imageForURL:(NSURL *)url {
	return [CKImageLoader getCachedImageForURL:url];
}

+ (UIImage *)imageForURL:(NSURL *)url withSize:(CGSize)size {
	//TODO
	//get image from transformer
	return nil;
}

@end
