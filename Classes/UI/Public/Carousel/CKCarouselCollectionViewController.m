//
//  CKCarouselCollectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCarouselCollectionViewController.h"
#import "CKTableViewCellController.h"
#import "NSObject+Bindings.h"
#import "CKCollectionController.h"

#import "CKTableViewCellController.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"



@interface CKCollectionViewController()
@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end



@interface UIViewWithIdentifier : UIView{
	id reuseIdentifier;
}
@property (nonatomic,retain) id reuseIdentifier;
@end

@implementation UIViewWithIdentifier
@synthesize reuseIdentifier;
- (void)dealloc{ self.reuseIdentifier = nil; [super dealloc]; }
@end


@interface CKCarouselCollectionViewController ()
@property (nonatomic, retain) NSMutableDictionary* headerViewsForSections;
@end

@implementation CKCarouselCollectionViewController{
	CKCarouselView* _carouselView;
	
	NSMutableDictionary* _headerViewsForSections;
	
	UIPageControl* _pageControl;
}


@synthesize carouselView = _carouselView;
@synthesize headerViewsForSections = _headerViewsForSections;
@synthesize pageControl = _pageControl;

- (void)dealloc {
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_pageControl",self]];
	[_carouselView release];
	_carouselView = nil;
	[_headerViewsForSections release];
	_headerViewsForSections = nil;
	[_pageControl release];
	_pageControl = nil;
	[super dealloc];
}

- (UIView*)contentView{
    return self.carouselView;
}

- (void)loadView {
	[super loadView];
	if (self.view == nil) {
		CGRect theViewFrame = [[UIScreen mainScreen] applicationFrame];
		UIView *theView = [[[UITableView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.view = theView;
	}
	
	if (self.carouselView == nil) {
		if ([self.view isKindOfClass:[CKCarouselView class]]) {
			// TODO: Assert - Should not be allowed
			self.carouselView = (CKCarouselView *)self.view;
		} else {
			CGRect theViewFrame = self.view.bounds;
			CKCarouselView *theCarouselView = [[[CKCarouselView alloc] initWithFrame:theViewFrame] autorelease];
			theCarouselView.delegate = self;
			theCarouselView.dataSource = self;
			theCarouselView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
			[self.view addSubview:theCarouselView];
			self.carouselView = theCarouselView;
		}
	}
	
	//DEBUG :
	self.carouselView.clipsToBounds = YES;
	self.carouselView.spacing = 20;
}

- (void)scrollToPage:(id)page{
	[self.carouselView setContentOffset:_pageControl.currentPage animated:YES];
}

- (void)updatePageControlPage:(id)page{
	_pageControl.currentPage = (_pageControl.currentPage + 1 >= self.carouselView.numberOfPages) ? self.carouselView.currentPage - 1 :  self.carouselView.currentPage +1;
	_pageControl.currentPage = self.carouselView.currentPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(_pageControl){
		[NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_pageControl",self]];
		[self.carouselView bind:@"currentPage" target:self action:@selector(updatePageControlPage:)];
		[self.carouselView bind:@"numberOfPages" toObject:_pageControl withKeyPath:@"numberOfPages"];
		[_pageControl bindEvent:UIControlEventTouchUpInside target:self action:@selector(scrollToPage:)];
		[NSObject endBindingsContext];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_pageControl",self]];
	self.carouselView = nil;
	self.pageControl = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self updateVisibleViewsRotation];
	
	[self reload];
    
	for(int i =0; i< [self numberOfSections];++i){
		[self fetchMoreIfNeededFromIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	[self.carouselView reloadData];
	[self.carouselView updateViewsAnimated:YES];
}

#pragma mark CKCarouselViewDataSource

- (NSInteger)numberOfSectionsInCarouselView:(CKCarouselView*)carouselView{
	return [self numberOfSections];
}

- (NSInteger)carouselView:(CKCarouselView*)carouselView numberOfRowsInSection:(NSInteger)section{
	return [self numberOfObjectsForSection:section];
}

- (CGSize) carouselView:(CKCarouselView*)carouselView sizeForViewAtIndexPath:(NSIndexPath*)indexPath{	
	return [self sizeForViewAtIndexPath:indexPath];
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier forIndexPath:(NSIndexPath*)indexPath{
	return [self.carouselView dequeueReusableViewWithIdentifier:identifier];
}

- (UIView*)carouselView:(CKCarouselView*)carouselView viewForRowAtIndexPath:(NSIndexPath*)indexPath{
	UIView* view = [self createViewAtIndexPath:indexPath];
	[self fetchMoreIfNeededFromIndexPath:indexPath];
	return view;
}

- (CGSize)sizeForViewAtIndexPath:(NSIndexPath*)indexPath{
    CKCollectionCellController* cellController = [self controllerAtIndexPath:indexPath];
    if([cellController isKindOfClass:[CKTableViewCellController class]]){
        CKTableViewCellController* controller = (CKTableViewCellController*)[self controllerAtIndexPath:indexPath];
        controller.sizeHasBeenQueriedByTableView = YES;
        if(controller.invalidatedSize){
            CGSize size;
            if(controller.sizeBlock){
                size = controller.sizeBlock(controller);
            }else{
                size = [controller computeSize];
            }
            [controller setSize:size notifyingContainerForUpdate:NO];
        }
        controller.sizeHasBeenQueriedByTableView = NO;
        return controller.size;
    }
    return [super sizeForViewAtIndexPath:indexPath];
}

#pragma mark CKCarouselViewDelegate

- (UIView*) carouselView:(CKCarouselView*)carouselView viewForHeaderInSection:(NSInteger)section{
	UIView* view = _headerViewsForSections ? [_headerViewsForSections objectForKey:[NSNumber numberWithInteger:section]] : nil;
	if(view){
		return view;
	}
	
	//if([_objectController conformsToProtocol:@protocol(CKObjectController) ]){
	if([self.objectController respondsToSelector:@selector(headerViewForSection:)]){
		view = [self.objectController headerViewForSection:section];
		if(_headerViewsForSections == nil){
			self.headerViewsForSections = [NSMutableDictionary dictionary];
		}
		if(view != nil){
			[_headerViewsForSections setObject:view forKey:[NSNumber numberWithInteger:section]];
		}
	}
	//}
	return view;
}

- (void) carouselView:(CKCarouselView*)carouselView viewDidDisappearAtIndexPath:(NSIndexPath*)indexPath{
	 CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
	if(controller && [controller respondsToSelector:@selector(viewDidDisappear)]){
		[controller viewDidDisappear];
	}
}

- (void) carouselView:(CKCarouselView*)carouselView viewDidAppearAtIndexPath:(NSIndexPath*)indexPath{
	 CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
	if(controller && [controller respondsToSelector:@selector(viewDidAppear:)]){
		UIView* view = [self.carouselView viewAtIndexPath:indexPath];
		[controller viewDidAppear:view];
	}	
}

- (void) carouselViewDidScroll:(CKCarouselView*)carouselView{
}

#pragma mark CKObjectControllerDelegate

- (void)didReload{
	[self.carouselView reloadData];
}

- (void)didBeginUpdates{
}

- (void)didEndUpdates{
	[self.carouselView reloadData];
}

- (void)didInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    //implement animations
}

- (void)didRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    //implement animations
}

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
	CGFloat offset = [self.carouselView pageForIndexPath:indexPath];
	[self.carouselView setContentOffset:offset animated:animated];
}

#pragma mark CKCarouselCollectionViewController

/*
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.carouselView viewAtIndexPath:indexPath];
}
 */

- (NSArray*)visibleIndexPaths{
	return [self.carouselView visibleIndexPaths];
}


- (void)updateSizeForControllerAtIndexPath:(NSIndexPath*)index{
    
}

@end
