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

@property (nonatomic, retain) CKWebRequest *request;
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, readonly) NSString *resizedImageCacheKey;
@property (nonatomic, readonly) BOOL hasSize;

- (UIImage *)getCachedImage;
- (void)setCachedImage:(UIImage *)image;

@end

//

@implementation CKImageLoader

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize imageURL = _imageURL;
@synthesize imageSize = _imageSize;
@synthesize aspectFill = _aspectFill;

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

- (BOOL)hasSize {
	return !CGSizeEqualToSize(self.imageSize, CGSizeZero);
}

#pragma mark Caching

+ (NSString *)cacheKeyForURL:(NSURL *)url size:(CGSize)size {
	return [NSString stringWithFormat:@"%@-%fx%f", url, size.width, size.height];
}

- (NSString *)resizedImageCacheKey {
	return [CKImageLoader cacheKeyForURL:self.imageURL size:self.imageSize];
}

- (UIImage *)getCachedImage {
	UIImage *image = [[CKCache sharedCache] imageForKey:self.resizedImageCacheKey];
	if (image) return image;

	image = [[CKCache sharedCache] imageForKey:self.imageURL];
	if (image == nil) return nil;
	
	if (self.hasSize == NO) return image;
	
	UIImage *resized = [image imageThatFits:self.imageSize crop:self.aspectFill];
	[[CKCache sharedCache] setImage:resized forKey:self.resizedImageCacheKey];
	return resized;
}

- (void)setCachedImage:(UIImage *)image {
	[[CKCache sharedCache] setImage:image forKey:self.imageURL];
	if (self.hasSize && CGSizeEqualToSize(image.size, self.imageSize) == NO) {
		UIImage *resized = [image imageThatFits:self.imageSize crop:self.aspectFill];
		[[CKCache sharedCache] setImage:resized forKey:self.resizedImageCacheKey];
	}
}

+ (UIImage *)imageForURL:(NSURL *)url {
	return [[CKCache sharedCache] imageForKey:url];
}

+ (UIImage *)imageForURL:(NSURL *)url withSize:(CGSize)size {
	return [[CKCache sharedCache] imageForKey:[CKImageLoader cacheKeyForURL:url size:size]];
}

#pragma mark Public API

- (void)loadImageWithContentOfURL:(NSURL *)url {
	[self cancel];
	self.imageURL = url;
	
	UIImage *image = [self getCachedImage];
	if (image) {
		[self.delegate imageLoader:self didLoadImage:image cached:YES];
		return;
	}
	
	self.request = [CKWebRequest requestWithURL:self.imageURL];
	self.request.delegate = self;
	[self.request start];
}

- (void)cancel {
	self.request.delegate = nil;
	[self.request cancel];
	self.request = nil;
}

#pragma mark CKWebRequestDelegate Protocol

- (void)request:(id)request didReceiveValue:(id)value {
	if ([value isKindOfClass:[UIImage class]]) {
		[self setCachedImage:value];
		if (self.delegate && [self.delegate respondsToSelector:@selector(imageLoader:didLoadImage:cached:)]) {
			[self.delegate imageLoader:self didLoadImage:[self getCachedImage] cached:NO];
		}
		return;
	}

	// Throws an error if the value is not an image
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_(@"Did not receive an image") forKey:NSLocalizedDescriptionKey];
	NSError *error = [NSError errorWithDomain:@"CKImageLoaderDomain" code:0 userInfo:userInfo];
	[self.delegate imageLoader:self didFailWithError:error];
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	[self.delegate imageLoader:self didFailWithError:error];
}

@end
