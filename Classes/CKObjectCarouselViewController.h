//
//  CKObjectCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewContainerController.h"
#import "CKCarouselView.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentCollection.h"


/** TODO
 */
@interface CKObjectCarouselViewController : CKItemViewContainerController<CKCarouselViewDataSource,CKCarouselViewDelegate,UIScrollViewDelegate> {
	CKCarouselView* _carouselView;
	
	NSMutableDictionary* _headerViewsForSections;
	
	UIPageControl* _pageControl;
}

@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;

- (void)postInit;
- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end
