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

@property (nonatomic, retain, readwrite) CKWebRequest *request;
@property (nonatomic, retain, readwrite) NSURL *imageURL;
@property (nonatomic, retain, readwrite) UIImage *image;

@end

//

@implementation CKImageView

@synthesize request = _request;
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
	
	UIImage *image = [[CKCache sharedCache] imageForKey:self.imageURL];
	if (image != nil) {
		self.image = image;
		[self.delegate imageViewDidFinishLoading:self];
		return;
	}
	
	self.image = nil;
	self.request = [CKWebRequest requestWithURL:self.imageURL];
	self.request.delegate = self;
	[self.request start];
}

- (void)reset {
	[self cancel];
	self.image = nil;
}

- (void)cancel {
	[self.request cancel];
	self.request = nil;
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

- (void)request:(id)request didReceiveValue:(id)value {
	if ([value isKindOfClass:[UIImage class]]) {
		// FIXME: We should cache both the source and the modified image
		UIImage *resized = [value imageThatFits:self.bounds.size crop:self.aspectFill];
		[[CKCache sharedCache] setImage:resized forKey:self.imageURL];
		self.image = resized;
		[self.delegate imageViewDidFinishLoading:self];
	}
	// FIXME: Should throw an error is the value is not an image
}

- (void)request:(id)request didFailLoadingWithError:(NSError *)error {
	[self reset];
	[self.delegate imageView:self didFailLoadingWithError:error];
}

@end
