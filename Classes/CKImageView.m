//
//  CKImageView.m
//  iPadSlideShow
//
//  Created by Fred Brunel on 10-05-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageView.h"
#import "CKCache.h"
#import <CloudKit/CKUIImage+Transformations.h>

@interface CKImageView ()

@property (nonatomic, retain, readwrite) CKImageLoader *imageLoader;
@property (nonatomic, retain, readwrite) NSURL *imageURL;
@property (nonatomic, retain, readwrite) UIImageView *imageView;

@end

//

@implementation CKImageView

@synthesize imageLoader = _imageLoader;
@synthesize imageURL = _imageURL;
@synthesize defaultImage = _defaultImage;
@synthesize delegate = _delegate;
@synthesize imageView = _imageView;

- (void)postInit{
	_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.imageView];
}

- (id)initWithCoder:(NSCoder *)decoder{
	[super initWithCoder:decoder];
	[self postInit];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self postInit];
    }
    return self;
}

- (void)dealloc {
	[self cancel];
	[_imageURL release];
	_imageURL = nil;
	self.defaultImage = nil;
	self.delegate = nil;
	self.imageView = nil;
	[super dealloc];
}

#pragma mark Public API

- (void)setImageURL:(NSURL *)url {
	[self loadImageWithContentOfURL:url];
}

- (void)loadImageWithContentOfURL:(NSURL *)url {
	if (self.image && [self.imageURL isEqual:url] && (self.image != self.defaultImage))
		return;

	[_imageURL release];
	_imageURL = [url retain];
	[self reload];
}

- (void)reload {
	[self reset];
	
	if(self.imageURL){
		UIImage *image = [CKImageLoader imageForURL:self.imageURL];
		if (image) {
			self.imageView.image = image;
			[self.delegate imageView:self didLoadImage:image cached:YES];
			return;
		}
		
		self.imageLoader = [[[CKImageLoader alloc] initWithDelegate:self] autorelease];
		[self.imageLoader loadImageWithContentOfURL:self.imageURL];
	}
}

- (void)reset {
	[self cancel];
	self.imageView.image = self.defaultImage;
}

- (void)cancel {
	self.imageLoader.delegate = nil;
	[self.imageLoader cancel];
	self.imageLoader = nil;
}

- (void)setDefaultImage:(UIImage *)image {
	[_defaultImage release];
	_defaultImage = [image retain];
	self.imageView.image = image;
}

- (UIImage *)image {
	return self.imageView.image;
}

- (void)setImageViewContentMode:(UIViewContentMode)theContentMode {
	self.imageView.contentMode = theContentMode;
}

- (UIViewContentMode)imageViewContentMode {
	return self.imageView.contentMode;
}

#pragma mark CKWebRequestDelegate Protocol

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached {
	self.imageView.image = image;
	[self.delegate imageView:self didLoadImage:image cached:NO];
}
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error {
	[self.delegate imageView:self didFailLoadWithError:error];
	[self reset];
}

@end
