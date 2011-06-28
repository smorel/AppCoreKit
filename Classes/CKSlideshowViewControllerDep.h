//
//  CKSlideshowViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-01.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** TODO
 */
@interface CKSlideshowViewControllerDep : UIViewController {
	NSArray *imagesPaths;			// Contains the paths to the images
	NSMutableDictionary *images;	// Contains the UIImages

	NSOperationQueue *queue;		// To handle asynchronous loading

	UIImageView *leftImageView;
	UIImageView *currentImageView;
	UIImageView *rightImageView;
	
	NSUInteger currentImageIndex;
	
	BOOL swiping;
	BOOL animating;
	CGFloat swipeStartX;
	
	UIBarButtonItem *previousButton;
	UIBarButtonItem *nextButton;
	
	// Save current status and navigation bar styles
	UIStatusBarStyle savedStatusBarStyle;
	UIBarStyle savedNavigationBarStyle;
	UIBarStyle savedToolbarStyle;
	UIColor	*savedNavigationBarTintColor;
	UIColor	*savedToolbarTintColor;
	BOOL savedNavigationBarTranslucent;
	BOOL savedToolbarTranslucent;
	BOOL savedNavigationBarHidden;
	BOOL savedToolbarHidden;
	
	BOOL useModalStyle;
	BOOL shouldHideControls;
}

@property (nonatomic, assign) BOOL shouldHideControls;
@property (nonatomic, assign) BOOL useModalStyle;
@property (nonatomic, assign) UIViewContentMode contentMode;

- (id)initWithImagePaths:(NSArray *)paths startAtIndex:(NSUInteger)index;
- (id)initWithImagePaths:(NSArray *)paths;

@end
