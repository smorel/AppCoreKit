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
#import <QuartzCore/QuartzCore.h>

@interface CKImageView ()

@property (nonatomic, retain, readwrite) CKImageLoader *imageLoader;
@property (nonatomic, retain, readwrite) UIImageView *imageView;
@property (nonatomic, retain, readwrite) UIButton *button;
@property (nonatomic, retain, readwrite) UIImageView *defaultImageView;
@property (nonatomic, retain, readwrite) UIActivityIndicatorView *activityIndicator;

- (void)updateViews:(BOOL)animated;

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
@synthesize defaultImageView = _defaultImageView;
@synthesize activityIndicator = _activityIndicator;


- (void)postInit{
	self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds]autorelease];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	self.defaultImageView = [[[UIImageView alloc] initWithFrame:self.bounds]autorelease];
	self.defaultImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
	
	//Activity indicator should start/stop and be added with the request ...
	self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];

	self.button = [UIButton buttonWithType:UIButtonTypeCustom];
	self.button.frame = self.bounds;
	self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.button.contentMode = UIViewContentModeScaleAspectFit;
	self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	
	self.fadeInDuration = 0;
	self.interactive = NO;
	_currentState = CKImageViewStateNone;
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
	[_activityIndicator release];
	_activityIndicator = nil;
	[_defaultImageView release];
	_defaultImageView = nil;
	self.defaultImage = nil;
	self.delegate = nil;
	self.imageView = nil;
	self.button = nil;
	[super dealloc];
}


#pragma mark Public API

- (void)setImage:(UIImage*)image updateAllViews:(BOOL)updateAllViews{
	self.imageView.image = image;
	[self.button setBackgroundImage:image forState:UIControlStateNormal];
	if(updateAllViews){
		[self updateViews:YES];
	}
}

- (void)setInteractive:(BOOL)bo{
	_interactive = bo;
	[self updateViews:YES];
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
	
	[self updateViews:YES];
}

- (void)reset {
	[self setImage:nil updateAllViews:NO];
	[self cancel];
}

- (void)cancel {
	self.imageLoader.delegate = nil;
	[self.imageLoader cancel];
	self.imageLoader = nil;
	[self updateViews:YES];
}

- (UIImage *)image {
	return self.imageView.image;
}

- (void)setDefaultImage:(UIImage *)image {
	[_defaultImage release];
	_defaultImage = [image retain];
	self.defaultImageView.image = image;
	
	[self updateViews:YES];
}

- (void)setImageViewContentMode:(UIViewContentMode)theContentMode {
	self.imageView.contentMode = theContentMode;
	self.defaultImageView.contentMode = theContentMode;
}

- (UIViewContentMode)imageViewContentMode {
	return self.imageView.contentMode;
}

#pragma mark CKWebRequestDelegate Protocol

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached {
	[self setImage:image updateAllViews:YES];
	[self.delegate imageView:self didLoadImage:image cached:NO];
}
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error {
	[self.delegate imageView:self didFailLoadWithError:error];
	[self reset];
}

- (void)removeCurrentView{
	switch(_currentState){
		case CKImageViewStateSpinner:{
			[self.activityIndicator stopAnimating];
			[self.activityIndicator removeFromSuperview];
			break;
		}
		case CKImageViewStateDefaultImage:{
			[self.defaultImageView removeFromSuperview];
			break;
		}
		case CKImageViewStateImage:{
			if(_interactive){
				[self.imageView removeFromSuperview];
			}
			else{
				[self.button removeFromSuperview];
			}
			break;
		}
	}
}

- (void)updateViews:(BOOL)animated{
	[self.layer removeAllAnimations];
	UIImage* image = [self image];
	if(!_defaultImage && !image){//spinner
		if(self.imageLoader){
			if(_currentState != CKImageViewStateSpinner){
				[self removeCurrentView];
				self.activityIndicator.center = self.center;
				self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
				self.activityIndicator.frame = CGRectMake(self.bounds.size.width / 2 - self.activityIndicator.bounds.size.width / 2,
														  self.bounds.size.height / 2 - self.activityIndicator.bounds.size.height / 2,
														  self.activityIndicator.bounds.size.width,
														  self.activityIndicator.bounds.size.height);
				[self addSubview:self.activityIndicator];
				[self.activityIndicator startAnimating];
				_currentState = CKImageViewStateSpinner;
			}
		}
	}
	else if(_defaultImage && !image){//_defaultImageView
		if(_currentState != CKImageViewStateDefaultImage){
			[self removeCurrentView];
			self.defaultImageView.frame = self.bounds;
			[self addSubview:self.defaultImageView];
			_currentState = CKImageViewStateDefaultImage;
		}
	}
	else if(image){//image or button
		if(_currentState != CKImageViewStateImage){
			if(animated && _fadeInDuration > 0 ){
				CATransition *animation = [CATransition animation];
				animation.duration = _fadeInDuration;	
				[self.layer addAnimation:animation forKey:nil];
			}
			
			[self removeCurrentView];
			if(_interactive){
				self.button.frame = self.bounds;
				[self addSubview:self.button];
			}
			else{
				self.imageView.frame = self.bounds;
				[self addSubview:self.imageView];
			}
			_currentState = CKImageViewStateImage;
		}
	}
	else{
		[self removeCurrentView];
	}
}

@end
