//
//  CKImageLoader.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageLoader.h"
#import "CKUIImage+Transformations.h"
#import "CKCache.h"
#import "CKLocalization.h"
#import "CKDebug.h"
#import "RegexKitLite.h"

NSString * const CKImageLoaderErrorDomain = @"CKImageLoaderErrorDomain";

@interface CKImageLoader ()
@property (nonatomic, retain) CKWebRequest2 *request;
@end

//

@implementation CKImageLoader

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize imageURL = _imageURL;

- (id)initWithDelegate:(id)delegate {
	if (self = [super init]) {
		self.delegate = delegate;
		//self.imageSize = CGSizeZero;
	}
	return self;
}

- (void)dealloc {
	[self cancel];
	self.imageURL = nil;
	[super dealloc];
}

#pragma mark Caching

+ (UIImage *)imageForURL:(NSURL*)URL {
	NSCachedURLResponse *cachedResponse = [CKWebRequest2 cachedResponseForURL:URL];
	if (cachedResponse) {
		return [UIImage imageWithData:cachedResponse.data];
	}
	return nil;
}

#pragma mark Public API

- (void)loadImageWithContentOfURL:(NSURL *)url {
	[self cancel];
	self.imageURL = url;
	
	UIImage *image = [CKImageLoader imageForURL:url];
	if (image) {
		[self.delegate imageLoader:self didLoadImage:image cached:YES];
	} else {
		//CHECK if url is web or disk and load from disk if needed ...
		if([self.imageURL isFileURL]){
			if(![[NSFileManager defaultManager] fileExistsAtPath:[self.imageURL path]] ){
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_(@"Could not find image file on disk") forKey:NSLocalizedDescriptionKey];
				NSError *error = [NSError errorWithDomain:CKImageLoaderErrorDomain code:1 userInfo:userInfo];
				if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didFailWithError:)]) {
					[self.delegate imageLoader:self didFailWithError:error];
				}
				CKDebugLog(@"Could not find image file on disk %@",self.imageURL);
			}
			else{
				image = [UIImage imageWithContentsOfFile:[self.imageURL path]];
				if (image) {
					[self.delegate imageLoader:self didLoadImage:image cached:YES];
				}
			}
		}
		else if([[self.imageURL scheme] isMatchedByRegex:@"^(http|https)$"]){
			self.request = [CKWebRequest2 requestWithURL:self.imageURL];
			self.request.delegate = self;
			[self.request startAsynchronous];
		}
	}
}

- (void)cancel {
	if(self.request){
		self.request.delegate = nil;
		[self.request cancel];
		self.request = nil;
	}
}

#pragma mark CKWebRequestDelegate Protocol

- (void)request:(id)request didReceiveValue:(id)value {
	if ([value isKindOfClass:[UIImage class]]) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didLoadImage:cached:)]) {
			[self.delegate imageLoader:self didLoadImage:(UIImage*)value cached:NO];
		}
	} else{
		// Throws an error if the value is not an image
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_(@"Did not receive an image") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:CKImageLoaderErrorDomain code:0 userInfo:userInfo];
		[self.delegate imageLoader:self didFailWithError:error];
	}
	
	//Delete the request not to cancel it later
	//self.request.delegate = nil;
	//self.request = nil;
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	[self.delegate imageLoader:self didFailWithError:error];
	//Delete the request not to cancel it later
	//self.request.delegate = nil;
	//elf.request = nil;
}

@end

#pragma mark Deprecated

@implementation CKImageLoader (Deprecated)

@dynamic imageSize;
@dynamic aspectFill;

+ (UIImage *)imageForURL:(NSURL *)url withSize:(CGSize)size {
	NSAssert(NO, @"DEPRECATED: Use CKThumbnailImageTransformer instead.");
	// TODO: Get image from a CKImageTransformer
	return nil;
}

@end
