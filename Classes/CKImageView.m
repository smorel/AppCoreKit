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
@property (nonatomic, retain, readwrite) UIImageView *imageView;
@property (nonatomic, retain, readwrite) UIButton *button;

@end

//

@implementation CKImageView

@synthesize imageLoader = _imageLoader;
@synthesize imageURL = _imageURL;
@synthesize defaultImage = _defaultImage;
@synthesize delegate = _delegate;
@synthesize imageView = _imageView;
@synthesize fadeInDuration = _fadeInDuration;
@synthesize interactive = _interactive;
@synthesize button = _button;


- (void)postInit{
	self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds]autorelease];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	self.button.frame = self.bounds;
	self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.button.contentMode = UIViewContentModeScaleAspectFit;
	self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	
	self.fadeInDuration = 0;
	self.interactive = NO;
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
	self.button = nil;
	[super dealloc];
}


#pragma mark Public API

- (void)setImage:(UIImage*)image{
	self.imageView.image = image;
	[self.button setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setInteractive:(BOOL)bo{
	_interactive = bo;
	if(bo){
		[self.imageView removeFromSuperview];
		[self addSubview:self.button];
	}
	else{
		[self.button removeFromSuperview];
		[self addSubview:self.imageView];
	}
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
	[self setImage:self.defaultImage];
}

- (void)cancel {
	self.imageLoader.delegate = nil;
	[self.imageLoader cancel];
	self.imageLoader = nil;
}

- (void)setDefaultImage:(UIImage *)image {
	[_defaultImage release];
	_defaultImage = [image retain];
	[self setImage:image];
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
	[self setImage:image];
	if(!cached && _fadeInDuration > 0){
		UIView* fadeView = _interactive ? (UIView*)self.button : (UIView*)self.imageView;
		fadeView.alpha = 0;
		[UIView beginAnimations:@"FadeInImage" context:nil];
		[UIView setAnimationDuration:_fadeInDuration];
		fadeView.alpha = 1;
		[UIView commitAnimations];
	}
	[self.delegate imageView:self didLoadImage:image cached:NO];
}
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error {
	[self.delegate imageView:self didFailLoadWithError:error];
	[self reset];
}

@end
