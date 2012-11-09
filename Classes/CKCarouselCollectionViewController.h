//
//  CKCarouselCollectionViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollectionViewController.h"
#import "CKCarouselView.h"
#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "CKCollection.h"


/**
 */
@interface CKCarouselCollectionViewController : CKCollectionViewController<CKCarouselViewDataSource,CKCarouselViewDelegate,UIScrollViewDelegate> 

///-----------------------------------
/// @name Getting/Setting the carousel and pageControl Views
///-----------------------------------

/**
 */
@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;

/**
 */
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;

///-----------------------------------
/// @name Scrolling
///-----------------------------------

/**
 */
- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end
