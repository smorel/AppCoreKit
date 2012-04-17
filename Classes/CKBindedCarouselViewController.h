//
//  CKBindedCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewContainerController.h"
#import "CKCarouselView.h"
#import "CKObjectController.h"
#import "CKItemViewControllerFactory.h"
#import "CKCollection.h"


/** TODO
 */
@interface CKBindedCarouselViewController : CKItemViewContainerController<CKCarouselViewDataSource,CKCarouselViewDelegate,UIScrollViewDelegate> {
	CKCarouselView* _carouselView;
	
	NSMutableDictionary* _headerViewsForSections;
	
	UIPageControl* _pageControl;
}

@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end
