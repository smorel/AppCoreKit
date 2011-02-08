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
//@property (nonatomic, retain, readwrite) UIImageView *imageView;
@property (nonatomic, retain, readwrite) UIButton *button;

@end

//

@implementation CKImageView

@synthesize imageLoader = _imageLoader;
@synthesize imageURL = _imageURL;
@synthesize defaultImage = _defaultImage;
@synthesize delegate = _delegate;
//@synthesize imageView = _imageView;
@synthesize button = _button;
@synthesize fadeInDuration = _fadeInDuration;
@synthesize interactive = _interactive;

- (void)setImageForAllStates : (UIImage*)image{
	[_button setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)postInit{
	//_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	//self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	_button = [[UIButton alloc] initWithFrame:self.bounds];
	self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.button.contentMode = UIViewContentModeScaleAspectFit;
	self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	
	self.fadeInDuration = 0;
	[self setImageForAllStates:nil];
	
	self.interactive = NO;
	[self addSubview:self.button];
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
	//self.imageView = nil;
	self.button = nil;
	[super dealloc];
}


#pragma mark Public API

- (void)setInteractive:(BOOL)bo{
	_interactive = bo;
	self.button.enabled = bo;
	self.button.adjustsImageWhenDisabled = bo;
	self.button.adjustsImageWhenHighlighted = bo;
}

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
		self.imageLoader = [[[CKImageLoader alloc] initWithDelegate:self] autorelease];
		[self.imageLoader loadImageWithContentOfURL:self.imageURL];
	}
}

- (void)reset {
	[self cancel];
	[self setImageForAllStates:self.defaultImage];
	//self.imageView.image = self.defaultImage;
}

- (void)cancel {
	self.imageLoader.delegate = nil;
	[self.imageLoader cancel];
	self.imageLoader = nil;
}

- (void)setDefaultImage:(UIImage *)image {
	[_defaultImage release];
	_defaultImage = [image retain];
	[self setImageForAllStates:image];
	//self.imageView.image = image;
}

- (UIImage *)image {
	return [self.button imageForState:UIControlStateNormal];
	//return self.imageView.image;
}

- (void)setImageViewContentMode:(UIViewContentMode)theContentMode {
	//self.imageView.contentMode = theContentMode;
}

- (UIViewContentMode)imageViewContentMode {
	//return self.imageView.contentMode;
}

#pragma mark CKWebRequestDelegate Protocol

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached {
	[self setImageForAllStates:image];
	//self.imageView.image = image;
	if(!cached && _fadeInDuration > 0){
		self.button.alpha = 0;
		[UIView beginAnimations:@"FadeInImage" context:nil];
		[UIView setAnimationDuration:_fadeInDuration];
		self.button.alpha = 1;
		[UIView commitAnimations];
	}
	[self.delegate imageView:self didLoadImage:image cached:NO];
}
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error {
	[self.delegate imageView:self didFailLoadWithError:error];
	[self reset];
}

@end
