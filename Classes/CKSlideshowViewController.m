//
//  CKSlideshowViewController.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKSlideshowViewController.h"
#import "CKUINavigationControllerAdditions.h"
#import "CKLocalization.h"
#import "CKConstants.h"
#import "CKBundle.h"

#define DELAY_CONTROLS_DISAPPEAR 5

@interface CKSlideshowViewController ()
@property (nonatomic, retain) UIView *imageContainerView;
@property (nonatomic, retain) NSArray *imagesPaths;
@property (nonatomic, retain) CKImageView *leftImageView;
@property (nonatomic, retain) CKImageView *rightImageView;
@property (nonatomic, retain) CKImageView *currentImageView;
@property (nonatomic, retain) NSDictionary *styles;
@end

@interface CKSlideshowViewController ()
- (NSUInteger)numberOfImages;
- (void)setTitleForIndex:(NSInteger)imageIndex;
- (CKImageView *)createImageView:(NSUInteger)imageIndex;
- (void)previousImage:(id)sender;
- (void)nextImage:(id)sender;
@end

//

@implementation CKSlideshowViewController

@synthesize delegate = _delegate;
@synthesize imagesPaths;
@synthesize currentImageIndex = _currentImageIndex;
@synthesize imageContainerView = _imageContainerView;
@synthesize shouldHideControls, useModalStyle;
@synthesize leftImageView, rightImageView, currentImageView;
@synthesize styles = _styles;

- (id)initWithImagePaths:(NSArray *)paths startAtIndex:(NSUInteger)index {
	if (self = [super init]) {
		self.imagesPaths = paths;
		_currentImageIndex = index;
	}
	return self;
}

- (id)initWithImagePaths:(NSArray *)paths {
	return [self initWithImagePaths:paths startAtIndex:0];
}

- (void)dealloc {
	[imagesPaths release];
	[previousButton release];
	[nextButton release];
	[leftImageView release];
	[currentImageView release];
	[rightImageView release];
	[_styles release];
	[_imageContainerView release];
	[super dealloc];
}

#pragma mark View Management

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor blackColor];
	self.view.opaque = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.contentMode = UIViewContentModeScaleAspectFit;

	if (self.imageContainerView == nil) {
		self.imageContainerView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
		self.imageContainerView.backgroundColor = [UIColor blackColor];
		self.imageContainerView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
		[self.view addSubview:self.imageContainerView];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.imageContainerView = nil;
	self.leftImageView = nil;
	self.currentImageView = nil;
	self.rightImageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.wantsFullScreenLayout = NO; // was: YES
	
	// Set the view style
	
	if (useModalStyle == NO) {
		self.styles = [self.navigationController getStyles];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	}
		
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.tintColor = nil;
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	self.navigationController.toolbar.tintColor = nil;
	self.navigationController.toolbar.translucent = YES;	
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	self.wantsFullScreenLayout = YES;

	if (self.navigationController.viewControllers.count <= 1) {
		UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Close") 
																		 style:UIBarButtonItemStyleBordered 
																		target:self 
																		action:@selector(dismissViewController)] autorelease];
		self.navigationItem.leftBarButtonItem = closeButton;
	}
	
	[self setTitleForIndex:_currentImageIndex];
	
	// Display the toolbar if more than 1 image
	if ([self numberOfImages] > 1) { 
		[self.navigationController setToolbarHidden:NO animated:animated];
	}
	
	// Setup image views
	
	if ([self numberOfImages] > 0) {
		if ((NSInteger)(_currentImageIndex - 1) >= 0) {
			self.leftImageView = [self createImageView:_currentImageIndex - 1];
			[self.imageContainerView addSubview:leftImageView];
		}				
		
		self.currentImageView = [self createImageView:_currentImageIndex];
		[self.imageContainerView addSubview:currentImageView];
		
		if (([self numberOfImages] > 1) && (_currentImageIndex + 1) < [self numberOfImages]) {
			self.rightImageView = [self createImageView:_currentImageIndex + 1];
			[self.imageContainerView addSubview:rightImageView];
		}
	}
	
	CGSize contentSize = self.view.bounds.size;
	leftImageView.frame = CGRectMake(-contentSize.width, 0.0f, contentSize.width, contentSize.height);
	currentImageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
	rightImageView.frame = CGRectMake(contentSize.width, 0.0f, contentSize.width, contentSize.height);
	
	leftImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// Add the toolbar buttons
	previousButton = [[UIBarButtonItem alloc] initWithImage:[CKBundle imageForName:@"CKSlideShowViewControllerArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(previousImage:)];
	nextButton = [[UIBarButtonItem alloc] initWithImage:[CKBundle imageForName:@"CKSlideShowViewControllerArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(nextImage:)];
	[self setToolbarItems:[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						   previousButton,
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						   nextButton,
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						   nil] 
				 animated:YES];
	
	if (_currentImageIndex == 0) previousButton.enabled = NO;
	if (_currentImageIndex >= ([self numberOfImages] - 1)) nextButton.enabled = NO;
	
	// Hide the navigationbar and the toolbar after a delay
	if (shouldHideControls) {
		[self performSelector:@selector(hideControls) withObject:nil afterDelay:DELAY_CONTROLS_DISAPPEAR];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	if (useModalStyle == NO) {
		[self.navigationController setStyles:self.styles animated:YES];
	}
		
	[super viewWillDisappear:animated];
}

- (void)setTitleForIndex:(NSInteger)imageIndex {
	NSUInteger count = [self numberOfImages];
	if (count == 0 || imageIndex >= count) return;
	self.title = [NSString stringWithFormat:NSLocalizedString(@"%d of %d", @"X images of X images total"), imageIndex+1, count];
}

- (NSUInteger)numberOfImages {
	if (self.imagesPaths) return self.imagesPaths.count;

	if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfImagesInSlideshowView:)]) {
		return [self.delegate numberOfImagesInSlideshowView:self];
	}

	return 0;
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	CGSize contentSize = self.view.bounds.size;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];

	leftImageView.frame = CGRectMake(-contentSize.width, 0.0f, contentSize.width, contentSize.height);
	currentImageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
	rightImageView.frame = CGRectMake(contentSize.width, 0.0f, contentSize.width, contentSize.height);
	
	[UIView commitAnimations];
}

#pragma mark Controls

- (void)showControls {	
	if (self.navigationController.navigationBar.alpha == 0) {
		[UIView beginAnimations:nil context:nil];
		self.navigationController.navigationBar.alpha = 1;
		self.navigationController.toolbar.alpha = 1;
		[UIView commitAnimations];
	}

	[NSObject cancelPreviousPerformRequestsWithTarget:self];	
	[self performSelector:@selector(hideControls) withObject:nil afterDelay:DELAY_CONTROLS_DISAPPEAR];
}

- (void)hideControls {
	if (self.navigationController.navigationBar.alpha == 0) return;

	[UIView beginAnimations:nil context:nil];
	self.navigationController.navigationBar.alpha = 0;
	self.navigationController.toolbar.alpha = 0;
	[UIView commitAnimations];
}

- (void)dismissViewController {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIImageView Management

- (CKImageView *)createImageView:(NSUInteger)imageIndex {
	if (imageIndex >= [self numberOfImages]) return nil;

	CKImageView *imageView = [[[CKImageView alloc] initWithFrame:self.view.bounds] autorelease];
	imageView.tag = imageIndex;
	imageView.opaque = YES;
	imageView.userInteractionEnabled = NO;
	imageView.backgroundColor = [UIColor blackColor];
	imageView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.clipsToBounds = YES;	
	
	if (self.imagesPaths) { 
		[imageView loadImageWithContentOfURL:[NSURL URLWithString:[self.imagesPaths objectAtIndex:imageIndex]]];
	} else if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowViewController:URLForImageAtIndex:)]) {
		NSURL *url = [self.delegate slideshowViewController:self URLForImageAtIndex:imageIndex];
		[imageView loadImageWithContentOfURL:url];
	}

	return imageView;
}

#pragma mark Image Navigation

- (void)beginScrollImages {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	leftImageView.hidden = NO;
	currentImageView.hidden = NO;
	rightImageView.hidden = NO;
}

- (void)scrollImages {
	[self setTitleForIndex:_currentImageIndex];
	
	CGSize contentSize = self.view.bounds.size;
	
	[UIView beginAnimations:@"swipe" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationWillStartSelector:@selector(scrollingAnimationWillStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(scrollingAnimationDidStop:context:)];	
	
	leftImageView.frame = CGRectMake(-contentSize.width, 0.0f, contentSize.width, contentSize.height);
	currentImageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
	rightImageView.frame = CGRectMake(contentSize.width, 0.0f, contentSize.width, contentSize.height);
	
	[UIView commitAnimations];
	
	if (_currentImageIndex == 0) previousButton.enabled = NO;
	else previousButton.enabled = YES;
	
	if (_currentImageIndex == [self numberOfImages]-1) nextButton.enabled = NO;
	else nextButton.enabled = YES;
}

- (void)scrollingAnimationWillStart:(NSString *)animationID context:(void *)context {
	animating = YES;
}

- (void)scrollingAnimationDidStop:(NSString *)animationID context:(void *)context {
	animating = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(slideshowViewController:imageDidAppearAtIndex:)]) {
		[self.delegate slideshowViewController:self imageDidAppearAtIndex:_currentImageIndex];
	}
}

- (void)nextImage:(id)sender {
	if (sender == nextButton) [self beginScrollImages];

	[self.leftImageView removeFromSuperview];
	
	self.leftImageView = self.currentImageView;
	self.currentImageView = self.rightImageView;
	
	_currentImageIndex++;
	if (_currentImageIndex < [self numberOfImages] - 1) {
		self.rightImageView = [self createImageView:_currentImageIndex + 1];
		self.rightImageView.hidden = YES;
		[self.imageContainerView addSubview:self.rightImageView];
	} else {
		self.rightImageView = nil;
	}
	
	if (sender == nextButton) [self scrollImages];
}

- (void)previousImage:(id)sender {
	if (sender == previousButton) [self beginScrollImages];
	
	[self.rightImageView removeFromSuperview];
	
	self.rightImageView = self.currentImageView;
	self.currentImageView = self.leftImageView;
	
	_currentImageIndex--;
	if (_currentImageIndex > 0) {
		self.leftImageView = [self createImageView:_currentImageIndex - 1];
		self.leftImageView.hidden = YES;
		[self.imageContainerView addSubview:self.leftImageView];
	} else {
		self.leftImageView = nil;
	}
	
	if (sender == previousButton) [self scrollImages];
}

#pragma mark Touch Management

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] != 1)
		return;
	
	if (animating)
		return;	
	
	swipeStartX = [[touches anyObject] locationInView:self.view].x;

	[self beginScrollImages];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] != 1)
		return;
	
	if (animating)
		return;	
	
	swiping = YES;
	CGFloat swipeDistance = [[touches anyObject] locationInView:self.view].x - swipeStartX;
	
	CGSize contentSize = self.view.bounds.size;
	
	leftImageView.frame = CGRectMake(swipeDistance - contentSize.width, 0.0f, contentSize.width, contentSize.height);
	currentImageView.frame = CGRectMake(swipeDistance, 0.0f, contentSize.width, contentSize.height);
	rightImageView.frame = CGRectMake(swipeDistance + contentSize.width, 0.0f, contentSize.width, contentSize.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (animating)
		return;	
	
	if (!swiping) {
		SEL selector = nil;
		
		if (shouldHideControls) {
			// FIXME: Refactor.
			if (self.navigationController.navigationBar.alpha == 0) selector = @selector(showControls);
			else selector = @selector(hideControls);
			if (selector != nil) [self performSelector:selector withObject:nil afterDelay:0.5];
		}
		
		return;
	}

	if (shouldHideControls) {
		if (self.navigationController.navigationBar.alpha == 1) [self hideControls];
	}
		
	NSUInteger count = [self numberOfImages];
	
	CGFloat swipeDistance = [[touches anyObject] locationInView:self.view].x - swipeStartX;
	if (_currentImageIndex > 0 && swipeDistance > 50.0f) {
		[self previousImage:nil];
	} else if (_currentImageIndex < count - 1 && swipeDistance < -50.0f) {
		[self nextImage:nil];
	}
	
	swiping = NO;

	[self scrollImages];
}

@end
