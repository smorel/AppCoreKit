//
//  CKSlideshowViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-01.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CKImageView.h"

@interface CKSlideshowViewController : UIViewController {
	id _delegate;
	NSArray *imagesPaths; // Contains the paths to the images
	IBOutlet UIView *_imageContainerView;
	CKImageView *leftImageView;
	CKImageView *currentImageView;
	CKImageView *rightImageView;	
	NSUInteger _currentImageIndex;
	BOOL swiping;
	BOOL animating;
	CGFloat swipeStartX;
	UIBarButtonItem *previousButton;
	UIBarButtonItem *nextButton;
	BOOL useModalStyle;
	BOOL canHideControls;
	NSDictionary *_styles;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL shouldHideControls;
@property (nonatomic, assign) BOOL useModalStyle;
@property (nonatomic, readonly) NSUInteger currentImageIndex;

- (id)initWithImagePaths:(NSArray *)paths startAtIndex:(NSUInteger)index;
- (id)initWithImagePaths:(NSArray *)paths;
- (void)showControls;
- (void)hideControls;

@end

//

@protocol CKSlideshowViewControllerDelegate

- (NSUInteger)numberOfImagesInSlideshowView:(CKSlideshowViewController *)slideshowController;
- (NSURL *)slideshowViewController:(CKSlideshowViewController *)slideshowController URLForImageAtIndex:(NSUInteger)index;

@optional
- (void)slideshowViewController:(CKSlideshowViewController *)slideshowController imageDidAppearAtIndex:(NSUInteger)index;

@end

//