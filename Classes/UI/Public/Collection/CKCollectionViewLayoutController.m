//
//  CKCollectionViewLayoutController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-22.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewLayoutController.h"
#import "CKCollectionViewCell.h"
#import "CKCollectionContentCellController.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"
#import "UIView+Snapshot.h"
#import "CKCollectionViewFlowLayout.h"
#import "CKCollectionContentCellController.h"
#import "NSObject+Invocation.h"
#import "Layout.h"

/*
 TODO : implement CKCollectionLayoutViewController with layout, managing cell controllers
 implements add/remove rows when collection updates
 implements fetching in collection when scrolling
 */

//This is needed as collection view deque differs from table view and it creates the view for us.
@interface CKCollectionViewCell()
@property(nonatomic,assign) BOOL hasBeenInitialized;
@end

@interface CKCollectionViewMorphableLayout()
@property(nonatomic,assign) CGFloat startMorphRatioForDelegate;
@property(nonatomic,assign) CGFloat endMorphRatioForDelegate;
@end

@interface CKCollectionViewLayoutController () <UICollectionViewDelegateFlowLayout>
//@property(nonatomic,retain,readwrite) UICollectionViewLayout* layout;
@property(nonatomic,retain,readwrite) UICollectionView* collectionView;
@property(nonatomic,retain,readwrite) UIImageView* beforeRotationImageView;
@property(nonatomic,retain,readwrite) UIImageView* afterRotationImageView;
@property(nonatomic,retain,readwrite) NSIndexPath* indexPathToReachAfterRotation;
@property(nonatomic,assign) BOOL collectionViewHasBeenReloaded;
@property (nonatomic, assign, readwrite) BOOL scrolling;
@end

@implementation CKCollectionViewLayoutController

- (Class)collectionViewClass{
    return [UICollectionView class];
}

- (void)postInit{
    [super postInit];
    self.collectionViewHasBeenReloaded = NO;
    self.optimizedOrientationChangedEnabled = YES;
}

#pragma Manages initialization

- (id)initWithLayout:(UICollectionViewLayout*)theLayout collection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory{
    self = [super initWithCollection:collection factory:factory];
    self.layout = theLayout;
    
    if([self.layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
        CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)self.layout;
        morphableLayout.delegate = self;
    }
    
    return self;
}


- (void)setupWithLayout:(UICollectionViewLayout*)theLayout collection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory{
    self.layout = theLayout;
    [self setupWithCollection:collection factory:factory];
}

- (void)setLayout:(UICollectionViewLayout *)theLayout{
    [self willChangeValueForKey:@"layout"];
    
    if([_layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
        CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)_layout;
        morphableLayout.delegate = nil;
    }
    
    [_layout release];
    _layout = [theLayout retain];
    
    if([theLayout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
        CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)theLayout;
        morphableLayout.delegate = self;
    }
    
    if([self isViewLoaded]){
        [self.collectionView setCollectionViewLayout:theLayout animated:YES];
    }
    
    [self didChangeValueForKey:@"layout"];
    
  //  [self cancelPeformBlock];//Cancel invalidate size calls
}

- (void)dealloc{
    if([self.layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
        CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)self.layout;
        morphableLayout.delegate = nil;
    }
    
    [_layout release];
    [_collectionView release];
    [_beforeRotationImageView release];
    [_afterRotationImageView release];
    [_indexPathToReachAfterRotation release];
    
    [super dealloc];
}

- (UIView*)contentView{
    return self.collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView = [[[[self collectionViewClass] alloc]initWithFrame:self.view.bounds collectionViewLayout:self.layout]autorelease];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
    
    //Device orientation change image views
    
    if(!self.beforeRotationImageView){ 
        self.beforeRotationImageView = [[[UIImageView alloc]initWithFrame:self.collectionView.bounds]autorelease];
        self.beforeRotationImageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.beforeRotationImageView.contentMode = UIViewContentModeScaleToFill;
        self.beforeRotationImageView.hidden = YES;
        [self.view addSubview:self.beforeRotationImageView];
    }
    
    if(!self.afterRotationImageView){
        self.afterRotationImageView = [[[UIImageView alloc]initWithFrame:self.collectionView.bounds]autorelease];
        self.afterRotationImageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.afterRotationImageView.contentMode = UIViewContentModeScaleToFill;
        self.afterRotationImageView.hidden = YES;
        [self.view addSubview:self.afterRotationImageView];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.collectionViewHasBeenReloaded){
        [self reload];
        self.collectionViewHasBeenReloaded = YES;
    }
    
    [self fetchMoreIfNeededFromIndexPath:nil];
}

#pragma mark Manages Device Orientation Change

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
    
    UICollectionViewLayout* myLayout = (UICollectionViewLayout*)[[self collectionView] collectionViewLayout];
    if([myLayout isKindOfClass:[CKCollectionViewLayout class]]){
        self.indexPathToReachAfterRotation = [(CKCollectionViewLayout*)myLayout indexPathForViewOfInterest];
    }else{
        self.indexPathToReachAfterRotation = [[self.collectionView indexPathsForSelectedItems]firstObject];
    }
    
    if(self.optimizedOrientationChangedEnabled){
        UIImage* image = [self.collectionView snapshot];
        self.beforeRotationImageView.hidden = NO;
        self.beforeRotationImageView.alpha = 1;
        self.afterRotationImageView.alpha = 0;
        self.beforeRotationImageView.image = image;
    }
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateRotationWithOrientation:toInterfaceOrientation];
}

- (void)updateRotationWithOrientation:(UIInterfaceOrientation)orientation{
    //Updates and snapshot new view !
    
    UICollectionViewLayout* myLayout = (UICollectionViewLayout*)[[self collectionView] collectionViewLayout];
    [myLayout invalidateLayout];
    
    [self.collectionView layoutSubviews];
    
    if([myLayout isKindOfClass:[CKCollectionViewLayout class]]){
        CGPoint p = [(CKCollectionViewLayout*)myLayout contentOffsetForViewAtIndexPath:self.indexPathToReachAfterRotation];
        [self.collectionView setContentOffset:p animated:NO];
    }else{
        if(self.indexPathToReachAfterRotation){
            [self.collectionView scrollToItemAtIndexPath:self.indexPathToReachAfterRotation atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
    }
    
    if(self.optimizedOrientationChangedEnabled){
        self.beforeRotationImageView.hidden = YES;
        
        UIImage* image = [self.collectionView snapshot];
        self.afterRotationImageView.hidden = NO;
        self.afterRotationImageView.image = image;
        
        self.beforeRotationImageView.hidden = NO;
        
        self.collectionView.hidden = YES;
        
        [UIView animateWithDuration:.3 animations:^{
            self.afterRotationImageView.alpha = 0;
            self.afterRotationImageView.alpha = 1;
        }completion:^(BOOL finished) {
            self.beforeRotationImageView.hidden = YES;
            self.afterRotationImageView.hidden = YES;
            self.collectionView.hidden = NO;
        }];
    }
}

#pragma Managing DataSource and cells

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self numberOfObjectsForSection:section];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIView* view = [self createViewAtIndexPath:indexPath];
    
    if([self.collectionView.collectionViewLayout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
        CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)self.collectionView.collectionViewLayout;
        if(morphableLayout.isMorphing){
            CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
            //TODO : Removes this check when CKCollectionContentCellController will be merged with CKCollectionCellController
            if([controller isKindOfClass:[CKCollectionContentCellController class]]){
                CKCollectionContentCellController* contentCellController = (CKCollectionContentCellController*)controller;
                CKCollectionCellContentViewController* contentViewController = [contentCellController contentViewController];
                if([contentViewController conformsToProtocol:@protocol(CKCollectionViewMorphableLayoutDelegate) ]){
                    
                    
                    id<CKCollectionViewMorphableLayoutDelegate> morphableDelegate = (id<CKCollectionViewMorphableLayoutDelegate> )contentViewController;
                    [morphableDelegate morphableLayout:morphableLayout willMorphFormRatio:morphableLayout.startMorphRatioForDelegate toRatio:morphableLayout.endMorphRatioForDelegate];
                }
            }
        }else{
            CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
            //TODO : Removes this check when CKCollectionContentCellController will be merged with CKCollectionCellController
            if([controller isKindOfClass:[CKCollectionContentCellController class]]){
                CKCollectionContentCellController* contentCellController = (CKCollectionContentCellController*)controller;
                CKCollectionCellContentViewController* contentViewController = [contentCellController contentViewController];
                if([contentViewController conformsToProtocol:@protocol(CKCollectionViewMorphableLayoutDelegate) ]){
                    id<CKCollectionViewMorphableLayoutDelegate> morphableDelegate = (id<CKCollectionViewMorphableLayoutDelegate> )contentViewController;
                    [morphableDelegate morphableLayout:morphableLayout didMorphFormRatio:morphableLayout.morphRatio toRatio:morphableLayout.morphRatio];
                }
            }
        }
    }
    
    if (![view isKindOfClass:[UICollectionViewCell class]])
        [NSException raise:NSGenericException format:@"invalid type for view"];
	
	return (UICollectionViewCell*)view;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    CKItemViewFlags flags = [self flagsForViewAtIndexPath:indexPath];
	return flags & CKItemViewFlagSelectable;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([self willSelectViewAtIndexPath:indexPath]){
		return YES;
	}
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self didSelectViewAtIndexPath:indexPath];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
	if(controller != nil && [controller isKindOfClass:[CKCollectionContentCellController class]] /* TODO : removes this check when everything moves in CKCollectionCellController */){
		[(CKCollectionContentCellController*)controller didDeselect];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
	CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
    if(controller){
        [controller viewDidDisappear];
    }
}


- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier forIndexPath:indexPath{
    [self.collectionView registerClass:[CKCollectionViewCell class] forCellWithReuseIdentifier:identifier];
	CKCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    CKCollectionCellController* cellController = [self controllerAtIndexPath:indexPath];
    if(!cell.hasBeenInitialized){
        [cellController initView:cell];
        [cellController applyStyle];
        cell.hasBeenInitialized = YES;
    }
    
    return cell;
}

#pragma mark CKObjectControllerDelegate

/*
- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[super objectController:controller insertObject:object atIndexPath:indexPath ];
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[super objectController:controller removeObject:object atIndexPath:indexPath ];
}*/

- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[super objectController:controller insertObjects:objects atIndexPaths:indexPaths ];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[super objectController:controller removeObjects:objects atIndexPaths:indexPaths ];
}

- (void)objectController:(id)controller insertSectionAtIndex:(NSInteger)index{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[super objectController:controller removeSectionAtIndex:index];
}

- (void)objectController:(id)controller removeSectionAtIndex:(NSInteger)index{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[super objectController:controller removeSectionAtIndex:index];
}


- (void)didReload{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
   // if(self.collectionView.window == nil)
    //    return;
    
    [self.collectionView reloadData];
}

- (void)didBeginUpdates{
    if(self.collectionView.window == nil)
        return;
	//To implement in inherited class
}

- (void)didEndUpdates{
    if(self.collectionView.window == nil)
        return;
}

- (void)didInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
	[self.collectionView insertItemsAtIndexPaths:indexPaths];
}

- (void)didRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.isViewDisplayed){
        self.collectionViewHasBeenReloaded = NO;
		return;
    }
    
    if(self.collectionView.window == nil)
        return;
    
    @try {
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    @finally {
        
    }
}

- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (NSArray*)visibleIndexPaths{
    return [self.collectionView indexPathsForVisibleItems];
}

#pragma mark Manage auto fetch

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if(self.autoFetchCollections){
        [self fetchMoreData];
    }
    self.scrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	if(self.autoFetchCollections){
        [self fetchMoreData];
    }
    self.scrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if(self.autoFetchCollections){
        [self fetchMoreData];
    }
    self.scrolling = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrolling = YES;
}


- (void)scrollToCellAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

#pragma mark CKCollectionViewMorphableLayoutDelegate

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout willMorphFormRatio:(CGFloat)ratio toRatio:(CGFloat)toRatio{
    for(NSIndexPath* indexPath in [self visibleIndexPaths]){
        CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
        
        //TODO : Removes this check when CKCollectionContentCellController will be merged with CKCollectionCellController
        if([controller isKindOfClass:[CKCollectionContentCellController class]]){
            CKCollectionContentCellController* contentCellController = (CKCollectionContentCellController*)controller;
            CKCollectionCellContentViewController* contentViewController = [contentCellController contentViewController];
            if(contentViewController.contentViewCell != nil){
                if([contentViewController conformsToProtocol:@protocol(CKCollectionViewMorphableLayoutDelegate) ]){
                    id<CKCollectionViewMorphableLayoutDelegate> morphableDelegate = (id<CKCollectionViewMorphableLayoutDelegate> )contentViewController;
                    [morphableDelegate morphableLayout:morphableLayout willMorphFormRatio:ratio toRatio:toRatio];
                }
            }
        }
    }
}

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout didMorphFormRatio:(CGFloat)ratio toRatio:(CGFloat)toRatio{
    for(NSIndexPath* indexPath in [self visibleIndexPaths]){
        CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
        
        //TODO : Removes this check when CKCollectionContentCellController will be merged with CKCollectionCellController
        if([controller isKindOfClass:[CKCollectionContentCellController class]]){
            CKCollectionContentCellController* contentCellController = (CKCollectionContentCellController*)controller;
            CKCollectionCellContentViewController* contentViewController = [contentCellController contentViewController];
            if(contentViewController.contentViewCell != nil){
                if([contentViewController conformsToProtocol:@protocol(CKCollectionViewMorphableLayoutDelegate) ]){
                    id<CKCollectionViewMorphableLayoutDelegate> morphableDelegate = (id<CKCollectionViewMorphableLayoutDelegate> )contentViewController;
                    [morphableDelegate morphableLayout:morphableLayout didMorphFormRatio:ratio toRatio:toRatio];
                }
            }
        }
    }
}

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout isMorphingWithRatio:(CGFloat)ratio velocity:(CGFloat)velocity{
    for(NSIndexPath* indexPath in [self visibleIndexPaths]){
        CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
        
        //TODO : Removes this check when CKCollectionContentCellController will be merged with CKCollectionCellController
        if([controller isKindOfClass:[CKCollectionContentCellController class]]){
            CKCollectionContentCellController* contentCellController = (CKCollectionContentCellController*)controller;
            CKCollectionCellContentViewController* contentViewController = [contentCellController contentViewController];
            if(contentViewController.contentViewCell != nil){
                if([contentViewController conformsToProtocol:@protocol(CKCollectionViewMorphableLayoutDelegate) ]){
                    id<CKCollectionViewMorphableLayoutDelegate> morphableDelegate = (id<CKCollectionViewMorphableLayoutDelegate> )contentViewController;
                    [morphableDelegate morphableLayout:morphableLayout isMorphingWithRatio:ratio velocity:velocity];
                }
            }
        }
    }
}

#pragma mark Flow Layout Management


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionContentCellController* controller = (CKCollectionContentCellController*)[self controllerAtIndexPath:indexPath];
    CGSize result = [controller preferredSizeConstraintToSize:CGSizeMake(self.collectionView.width,self.collectionView.height)];
    return result;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}

- (void)updateSizeForControllerAtIndexPath:(NSIndexPath*)index{
    //[self.collectionView performBatchUpdates:^(){} completion:^(BOOL finished){}];
}

@end
