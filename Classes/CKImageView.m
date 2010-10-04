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

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		_imageView = [[UIImageView alloc] initWithFrame:frame];
		self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.imageView];
    }
    return self;
}

- (void)dealloc {
	[self cancel];
	self.imageURL = nil;
	self.defaultImage = nil;
	self.delegate = nil;
	self.imageView = nil;
	[super dealloc];
}

#pragma mark Public API

- (void)loadImageWithContentOfURL:(NSURL *)url {
	if (self.image && [self.imageURL isEqual:url] && (self.image != self.defaultImage))
		return;

	self.imageURL = url;
	[self reload];
}

- (void)reload {
	[self reset];
	
	UIImage *image = [CKImageLoader imageForURL:self.imageURL];
	if (image) {
		self.imageView.image = image;
		[self.delegate imageView:self didLoadImage:image cached:YES];
		return;
	}
	
	self.imageLoader = [[[CKImageLoader alloc] initWithDelegate:self] autorelease];
	[self.imageLoader loadImageWithContentOfURL:self.imageURL];
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
