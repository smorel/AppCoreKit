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
@property (nonatomic, retain, readwrite) UIImage *image;

@end

//

@implementation CKImageView

@synthesize imageLoader = _imageLoader;
@synthesize imageURL = _imageURL;
@synthesize defaultImage = _defaultImage;
@synthesize image = _image;
@synthesize aspectFill = _aspectFill;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)dealloc {
	[self cancel];
	self.imageURL = nil;
	self.image = nil;
	self.defaultImage = nil;
	self.delegate = nil;
	[super dealloc];
}

#pragma mark Public API

- (void)loadImageWithContentOfURL:(NSURL *)url {
	if (self.image && [self.imageURL isEqual:url])
		return;

	self.imageURL = url;
	[self reload];
}

- (void)reload {
	[self cancel];
	
	UIImage *image = [CKImageLoader imageForURL:self.imageURL withSize:self.bounds.size];
	if (image) {
		self.image = image;
		[self.delegate imageView:self didLoadImage:image cached:YES];
		return;
	}
	
	self.image = nil;
	self.imageLoader = [[[CKImageLoader alloc] initWithDelegate:self] autorelease];
	self.imageLoader.imageSize = self.bounds.size;
	self.imageLoader.aspectFill = self.aspectFill;
	[self.imageLoader loadImageWithContentOfURL:self.imageURL];
}

- (void)reset {
	[self cancel];
	self.image = nil;
}

- (void)cancel {
	self.imageLoader.delegate = nil;
	[self.imageLoader cancel];
	self.imageLoader = nil;
}

#pragma mark Image

- (void)setImage:(UIImage *)theImage {
	[_image release];
	_image = theImage ? [theImage retain] : nil;
	[self setNeedsDisplay];
}

#pragma mark Draw Image

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (self.image) {
		[self.image drawInRect:rect];
	} else if (self.defaultImage) {
		[self.defaultImage drawInRect:rect];
	} else {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextClearRect(ctx, rect);
	}
}

#pragma mark CKWebRequestDelegate Protocol

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached {
	self.image = image;
	[self.delegate imageView:self didLoadImage:image cached:NO];
}
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error {
	[self.delegate imageView:self didFailLoadWithError:error];
	[self reset];
}

@end
