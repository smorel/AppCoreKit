//
//  CKObjectCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController.h"
#import "CKCarouselView.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentCollection.h"

@interface CKObjectCarouselViewController : CKUIViewController<CKCarouselViewDataSource,CKCarouselViewDelegate,CKObjectControllerDelegate,UIScrollViewDelegate> {
	CKCarouselView* _carouselView;
	
	id _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	
	int _numberOfObjectsToprefetch;
	NSMutableDictionary* _cellsToControllers;
	NSMutableDictionary* _headerViewsForSections;
	NSMutableDictionary* _controllersForIdentifier;
	NSMutableDictionary* _params;
	
	UIPageControl* _pageControl;
}

@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKObjectViewControllerFactory* controllerFactory;
@property (nonatomic, assign) int numberOfObjectsToprefetch;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory;
- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

//private
- (void)postInit;

@end
