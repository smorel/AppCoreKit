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
@property (nonatomic, retain, readwrite) UIImage *image;

@end

//

@implementation CKImageView

@synthesize request = _request;
@synthesize imageURL = _imageURL;
@synthesize image = _image;
@synthesize aspectFill = _aspectFill;
@synthesize borderColor = _borderColor;
@synthesize cornerRadius = _cornerRadius;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)dealloc {
	[self cancel];
	[_imageURL release];
	[_image release];
	self.delegate = nil;
	[super dealloc];
}

#pragma mark Public API

- (void)setImageURL:(NSString *)theImageURL {
	if (self.image && [self.imageURL isEqualToString:theImageURL])
		return;
	
	[_imageURL release];
	_imageURL = [theImageURL retain];
	[self reload];
}

- (void)reload {
	[self cancel];
	
	UIImage *image = [[CKCache sharedCache] imageForKey:self.imageURL];
	if (image != nil) {
		self.image = image;
		return;
	}
	
	self.image = nil;
	self.request = [CKWebRequest requestWithURLString:self.imageURL params:nil];
	self.request.delegate = self;
	[self.request start];
}

- (void)cancel {
	[self.request cancel];
	self.request = nil;
}

#pragma mark Draw Image

- (void)drawRect:(CGRect)rect {
	if (self.image) {
		[self.image drawInRect:rect];
	}
}

#pragma mark CKWebRequestDelegate Protocol

- (void)request:(id)request didReceiveValue:(id)value {
	if ([value isKindOfClass:[UIImage class]]) {
		UIImage *source = [(UIImage *)value imageThatFits:self.bounds.size crop:self.aspectFill];
		
		if (self.borderColor && (self.cornerRadius == 0)) {
			self.image = source;
		} else {
			self.image = [source imageByAddingBorderWithColor:self.borderColor cornerRadius:self.cornerRadius];
		}
		
		// FIXME: Here we cache the modified image, maybe we should instead cache the source image.
		
		[[CKCache sharedCache] setImage:self.image forKey:self.imageURL];
		
		[self setNeedsDisplay];
		[self.delegate imageViewDidFinishLoading:self];
	}
	// FIXME: Should throw an error is the value is not an image
}

- (void)request:(id)request didFailLoadingWithError:(NSError *)error {
	self.request = nil;
	[self.delegate imageView:self didFailLoadingWithError:error];	
}

@end
