//
//  CKObjectCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCarouselView.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKNSDictionary+TableViewAttributes.h"

@interface CKObjectCarouselViewController : UIViewController<CKCarouselViewDataSource,CKCarouselViewDelegate,CKObjectControllerDelegate> {
	CKCarouselView* _carouselView;
	
	id _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	
	int _numberOfObjectsToprefetch;
	NSMutableDictionary* _cellsToControllers;
	NSMutableDictionary* _headerViewsForSections;
	
	UIPageControl* _pageControl;
}

@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKObjectViewControllerFactory* controllerFactory;
@property (nonatomic, assign) int numberOfObjectsToprefetch;

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory;
- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end
