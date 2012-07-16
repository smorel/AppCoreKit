//
//  CKSlideshowViewController.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKSlideshowViewControllerDep.h"
#import "CKLocalization.h"
#import "CKConstants.h"
#import "ASIHTTPRequest.h"
#import "CKBundle.h"

#define DELAY_CONTROLS_DISAPPEAR 5

@interface CKSlideshowViewControllerDep ()
@property (nonatomic, retain) NSArray *imagesPaths;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) UIImageView *leftImageView;
@property (nonatomic, retain) UIImageView *rightImageView;
@property (nonatomic, retain) UIImageView *currentImageView;
@end

@interface CKSlideshowViewControllerDep (Private)
- (void)saveStyles;
- (void)restoreStyles;
- (void)setTitleForIndex:(NSInteger)imageIndex;
- (void)grabURL:(NSString *)urlString forImageView:(UIImageView *)imageView;
- (UIImageView *)createImageView:(NSUInteger)imageIndex;
- (void)previousImage:(id)sender;
- (void)nextImage:(id)sender;
@end

//

@implementation CKSlideshowViewControllerDep

@synthesize imagesPaths, images, queue;
@synthesize leftImageView, rightImageView, currentImageView;
@synthesize shouldHideControls, useModalStyle, contentMode;

- (id)initWithImagePaths:(NSArray *)paths startAtIndex:(NSUInteger)index {
	if (self = [super init]) {
		self.imagesPaths = paths;
		self.images = [NSMutableDictionary dictionaryWithCapacity:imagesPaths.count];
		self.queue = [[[NSOperationQueue alloc] init] autorelease];
		self.contentMode = UIViewContentModeScaleAspectFit;
		currentImageIndex = index;
	}
	return self;
}

- (id)initWithImagePaths:(NSArray *)paths {
	return [self initWithImagePaths:paths startAtIndex:0];
}

- (void)dealloc {
	[imagesPaths release];
	[images release];
	[queue release];
	[previousButton release];
	[nextButton release];
	[leftImageView release];
	[currentImageView release];
	[rightImageView release];
	[super dealloc];
}

#pragma mark View Management

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.opaque = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.wantsFullScreenLayout = NO; // was: YES
	
	// Set the view style
	
	if (useModalStyle == NO) {
		[self saveStyles];
	}
		
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	self.navigationController.toolbar.translucent = YES;	
	[self.navigationController setNavigationBarHidden:NO animated:animated];

	if (self.navigationController.viewControllers.count <= 1) {
		UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Close") 
																		 style:UIBarButtonItemStyleBordered 
																		target:self 
																		action:@selector(dismissViewController)] autorelease];
		self.navigationItem.leftBarButtonItem = closeButton;
	}
	
	[self setTitleForIndex:currentImageIndex];
	
	// Display the toolbar if more than 1 image
	if (self.imagesPaths.count > 1) [self.navigationController setToolbarHidden:NO animated:animated];
	
	// Setup image views
	
	if (imagesPaths.count > 0) {	
		if ((NSInteger)(currentImageIndex - 1) >= 0) {
			self.leftImageView = [self createImageView:currentImageIndex - 1];
			[self.view addSubview:leftImageView];
		}
		
		self.currentImageView = [self createImageView:currentImageIndex];
		[self.view addSubview:currentImageView];
		
		if ((imagesPaths.count > 1) && (currentImageIndex + 1) < imagesPaths.count) {
			self.rightImageView = [self createImageView:currentImageIndex + 1];
			[self.view addSubview:rightImageView];
		}
	}
	
	CGSize contentSize = self.view.bounds.size;
	
	leftImageView.frame = CGRectMake(-contentSize.width, 0.0f, contentSize.width, contentSize.height);
	currentImageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
	rightImageView.frame = CGRectMake(contentSize.width, 0.0f, contentSize.width, contentSize.height);
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
	
	previousButton.enabled = NO;
	
	// Hide the navigationbar and the toolbar after a delay
	if (shouldHideControls) {
		[self performSelector:@selector(hideControls) withObject:nil afterDelay:DELAY_CONTROLS_DISAPPEAR];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[queue cancelAllOperations];
	
	if (useModalStyle == NO) {
		[self restoreStyles];
		[self.navigationController setNavigationBarHidden:savedNavigationBarHidden animated:animated];
		[self.navigationController setToolbarHidden:savedToolbarHidden animated:animated];
		[self setToolbarItems:[NSArray array] animated:YES];
	}
		
	[super viewWillDisappear:animated];
}

- (void)setTitleForIndex:(NSInteger)imageIndex {
	if (self.imagesPaths == nil || [self.imagesPaths count] == 0 || imageIndex >= [self.imagesPaths count]) return;
	self.title = [NSString stringWithFormat:NSLocalizedString(@"%d of %d", @"X images of X images total"), imageIndex+1, [self.imagesPaths count]];
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	CGSize contentSize = self.view.bounds.size;
	UIView *spinner = nil;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];

	// FIXME: Does not, this resize the spinner 3 times because of same identifier.
	// FIXME: Also, there is no need for the computation, just do spinner.center = imageView.center.
	
	leftImageView.frame = CGRectMake(-contentSize.width, 0.0f, contentSize.width, contentSize.height);
	spinner = (UIActivityIndicatorView *)[leftImageView viewWithTag:1000];
	if (spinner) spinner.frame = CGRectMake(leftImageView.frame.size.width/2 - spinner.frame.size.width/2, 
														 leftImageView.frame.size.height/2 - spinner.frame.size.height/2,
														 spinner.frame.size.width,
														 spinner.frame.size.height);
	
	currentImageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
	spinner = (UIActivityIndicatorView *)[currentImageView viewWithTag:1000];
	if (spinner) spinner.frame = CGRectMake(currentImageView.frame.size.width/2 - spinner.frame.size.width/2, 
														 currentImageView.frame.size.height/2 - spinner.frame.size.height/2,
														 spinner.frame.size.width,
														 spinner.frame.size.height);
	
	rightImageView.frame = CGRectMake(contentSize.width, 0.0f, contentSize.width, contentSize.height);
	spinner = (UIActivityIndicatorView *)[rightImageView viewWithTag:1000];
	if (spinner) spinner.frame = CGRectMake(rightImageView.frame.size.width/2 - spinner.frame.size.width/2, 
														 rightImageView.frame.size.height/2 - spinner.frame.size.height/2,
														 spinner.frame.size.width,
														 spinner.frame.size.height);
	
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
	[images removeAllObjects];
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	return;
}

#pragma mark -
#pragma mark Styles

- (void)saveStyles {
	savedStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	savedNavigationBarStyle = self.navigationController.navigationBar.barStyle;
	savedToolbarStyle = self.navigationController.toolbar.barStyle;
	savedNavigationBarTintColor = [self.navigationController.navigationBar.tintColor retain];
	savedToolbarTintColor = [self.navigationController.toolbar.tintColor retain];
	savedNavigationBarTranslucent = self.navigationController.navigationBar.translucent;
	savedToolbarTranslucent = self.navigationController.toolbar.translucent;
	savedNavigationBarHidden = self.navigationController.navigationBar.hidden;
	savedToolbarHidden = self.navigationController.toolbar.hidden;
}

- (void)restoreStyles {
	[UIApplication sharedApplication].statusBarStyle = savedStatusBarStyle;
	self.navigationController.navigationBar.barStyle = savedNavigationBarStyle;
	self.navigationController.toolbar.barStyle = savedToolbarStyle;
	if (savedNavigationBarTintColor) self.navigationController.navigationBar.tintColor = savedNavigationBarTintColor;
	if (savedToolbarTintColor) self.navigationController.toolbar.tintColor = savedToolbarTintColor;
	self.navigationController.navigationBar.translucent = savedNavigationBarTranslucent;
	self.navigationController.toolbar.translucent = savedToolbarTranslucent;
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

#pragma mark URL Loading

- (void)grabURL:(NSString *)urlString forImageView:(UIImageView *)imageView {
	
	// Insert a spinner in the ImageView
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.tag = 1000;
	spinner.center = imageView.center;
	
	[spinner startAnimating];
	[imageView addSubview:spinner];
	[spinner release];
	
	// Create a request to grab the data
	NSURL *url = [NSURL URLWithString:urlString];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	request.userInfo = [NSDictionary dictionaryWithObject:imageView forKey:@"ImageView"];
	[[self queue] addOperation:request];
}

- (void)requestDone:(ASIHTTPRequest *)request {
	NSData *imgData = [request responseData];
	
	UIImage *image = [UIImage imageWithData:imgData];
	UIImageView *imageView = [request.userInfo objectForKey:@"ImageView"];
	[imageView setImage:image];
	[[imageView viewWithTag:1000] removeFromSuperview];
	
	// Store the image in the cache
	[images setObject:image forKey:[NSNumber numberWithInt:imageView.tag]];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
	UIImageView *imageView = [request.userInfo objectForKey:@"ImageView"];
	[[imageView viewWithTag:1000] removeFromSuperview];
}

#pragma mark UIImageView Management

- (UIImageView *)createImageView:(NSUInteger)imageIndex {
	if (imageIndex >= [imagesPaths count]) return nil;

	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
	imageView.tag = imageIndex;
	imageView.opaque = YES;
	imageView.userInteractionEnabled = NO;
	imageView.backgroundColor = [UIColor blackColor];
	imageView.contentMode = self.contentMode;
	imageView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	imageView.clipsToBounds = YES;
	
	// Image already in the cache
	UIImage *image = [images objectForKey:[NSNumber numberWithInt:imageIndex]];
	if (image) {
		[imageView setImage:image];
		return imageView;
	}
	
	// Load the image from URL
	NSString *imagePath = [imagesPaths objectAtIndex:imageIndex];
	if (imagePath != nil && [imagePath length] >= 7 && [imagePath hasPrefix:@"http://"]) {
		[self grabURL:imagePath forImageView:imageView];
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
	[self setTitleForIndex:currentImageIndex];
	
	CGSize contentSize = self.view.bounds.size;
	
	[UIView beginAnimations:@"swipe" context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(scrollingAnimationWillStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(scrollingAnimationDidStop:context:)];
	
	leftImageView.frame = CGRectMake(-contentSize.width, 0.0f, contentSize.width, contentSize.height);
	currentImageView.frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
	rightImageView.frame = CGRectMake(contentSize.width, 0.0f, contentSize.width, contentSize.height);
	
	[UIView commitAnimations];
	
	if (currentImageIndex == 0) previousButton.enabled = NO;
	else previousButton.enabled = YES;
	
	if (currentImageIndex == [self.imagesPaths count]-1) nextButton.enabled = NO;
	else nextButton.enabled = YES;
}

- (void)scrollingAnimationWillStart:(NSString *)animationID context:(void *)context {
	animating = YES;
}

- (void)scrollingAnimationDidStop:(NSString *)animationID context:(void *)context {
	animating = NO;
}
													
- (void)nextImage:(id)sender {
	if (sender == nextButton) [self beginScrollImages];

	[self.leftImageView removeFromSuperview];
	
	self.leftImageView = self.currentImageView;
	self.currentImageView = self.rightImageView;
	
	currentImageIndex++;
	if (currentImageIndex < [self.imagesPaths count] - 1) {
		self.rightImageView = [self createImageView:currentImageIndex + 1];
		self.rightImageView.hidden = YES;
		[self.view addSubview:self.rightImageView];
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
	
	currentImageIndex--;
	if (currentImageIndex > 0) {
		self.leftImageView = [self createImageView:currentImageIndex - 1];
		self.leftImageView.hidden = YES;
		[self.view addSubview:self.leftImageView];
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
	
	NSLog(@"touchesBegan");
	
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
		
	NSUInteger count = [imagesPaths count];
	
	CGFloat swipeDistance = [[touches anyObject] locationInView:self.view].x - swipeStartX;
	if (currentImageIndex > 0 && swipeDistance > 50.0f) {
		[self previousImage:nil];
	}
	else if (currentImageIndex < count - 1 && swipeDistance < -50.0f) {
		[self nextImage:nil];
	}
	
	swiping = NO;

	[self scrollImages];
}

@end
