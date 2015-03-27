//
//  CKCollectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionViewController.h"
#import "CKCollectionViewFlowLayout.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"

#import "CKSheetController.h"
#import "CKRuntime.h"
#import <objc/runtime.h>

@interface CKCollectionViewController()
@property (nonatomic,retain,readwrite) CKSectionContainer* sectionContainer;
@property (nonatomic, assign, readwrite) BOOL scrolling;
@property(nonatomic,retain,readwrite) CKPassThroughView* backgroundView;
@property(nonatomic,retain,readwrite) CKPassThroughView* foregroundView;
@end

@implementation CKCollectionViewController

- (instancetype)init{
    return [self initWithCollectionViewLayout:[[[CKCollectionViewFlowLayout alloc]init]autorelease]];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    [self postInit];
    return self;
}

- (void)postInit{
    [super postInit];
    self.stickySelectionEnabled = NO;
    self.scrolling = NO;
    self.sectionContainer = [[CKSectionContainer alloc]initWithDelegate:self];
}

- (void)dealloc{
    [self.backgroundView removeFromSuperview];
    [self.foregroundView removeFromSuperview];
    
    [self clearBindingsContextWithScope:@"foregroundView"];
    [self clearBindingsContextWithScope:@"backgroundView"];

    [_sectionContainer release];
    [_backgroundView release];
    [_foregroundView release];
    [super dealloc];
}

- (void)setCollectionViewLayout:(UICollectionViewLayout*)collectionViewLayout animated:(BOOL)animated{
    if([self isViewLoaded]){
        [self.collectionView setCollectionViewLayout:collectionViewLayout animated:animated];
    }else{
        //self.collectionViewLayout = collectionViewLayout;
        int i =3;
    }
}

#pragma Managing Decorator Views

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.backgroundView = [[[CKPassThroughView alloc]initWithFrame:self.collectionView.bounds]autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.backgroundView.flexibleSize = YES;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.foregroundView = [[[CKPassThroughView alloc]initWithFrame:self.collectionView.bounds]autorelease];
    self.foregroundView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.foregroundView.flexibleSize = YES;
    self.foregroundView.backgroundColor = [UIColor clearColor];

    
    self.collectionView.backgroundColor = [UIColor clearColor];
}


- (void)presentsBackgroundView{
    if(self.view  && [self.backgroundView superview] == nil){
        [self.view insertSubview:self.backgroundView belowSubview:self.collectionView];
        
        [self beginBindingsContextWithScope:@"backgroundView"];
        [self.collectionView bind:@"frame" executeBlockImmediatly:YES withBlock:^(id value) {
            [self.backgroundView setFrame:self.collectionView.frame animated:NO];
        }];
        [self endBindingsContext];
    }
}

- (void)presentsForegroundView{
    if(self.view  && [self.foregroundView superview] == nil){
        [self.view insertSubview:self.foregroundView aboveSubview:self.collectionView];
        
        [self beginBindingsContextWithScope:@"foregroundView"];
        [self.collectionView bind:@"frame" executeBlockImmediatly:YES withBlock:^(id value) {
            [self.foregroundView setFrame:self.collectionView.frame animated:NO];
        }];
        [self endBindingsContext];
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self presentsBackgroundView];
    [self presentsForegroundView];
}

#pragma Managing Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.sectionContainer handleViewWillAppearAnimated:animated];
    
    [self fetchMoreData];
    
    //for(NSIndexPath* indexPath in self.selectedIndexPaths){
    //    [self.pickerView selectRow:indexPath.row inComponent:indexPath.section animated:NO];
    //}
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.sectionContainer handleViewDidAppearAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[self.view superview] endEditing:YES];
    
    [self.sectionContainer handleViewWillDisappearAnimated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.sectionContainer handleViewDidDisappearAnimated:animated];
}


#pragma Managing Batch Updates

- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^)(BOOL finished))completion{
    if(self.state == CKViewControllerStateDidAppear){
        [self.collectionView performBatchUpdates:updates completion:completion];
    }else{
        if(updates){
            updates();
        }
        if(completion){
            completion(YES);
        }
    }
}


#pragma mark CKSectionedViewController protocol


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad)
        return;
    
    [self performBatchUpdates:^{
        [self.collectionView insertSections:indexes];
    } completion:nil];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad)
        return;
    
    [self performBatchUpdates:^{
        [self.collectionView deleteSections:indexes];
    } completion:nil];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad)
        return;
    
    [self performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    } completion:nil];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad)
        return;
    
    [self performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    } completion:nil];
}

- (UIView*)contentView{
    return self.collectionView;
}

- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:animated ];
}


#pragma mark Managing Content

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sectionContainer.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    return s.controllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    NSString* reuseIdentifier = [controller reuseIdentifier];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    UICollectionViewCell* cell = (UICollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.contentView.flexibleSize = YES;
    return (UICollectionViewCell*)[self.sectionContainer viewForControllerAtIndexPath:indexPath reusingView:cell];
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidAppear)
        return;
    
    if(controller.state != CKViewControllerStateWillAppear){
        [controller viewWillAppear:NO];
    }
    if(controller.state != CKViewControllerStateDidAppear){
        [controller viewDidAppear:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidDisappear)
        return;
    
    if(controller.state != CKViewControllerStateWillDisappear){
        [controller viewWillDisappear:NO];
    }
    if(controller.state != CKViewControllerStateDidDisappear){
        [controller viewDidDisappear:NO];
    }
}

#pragma mark Managing Supplementary Views

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        int i =3;
    }else if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        int i =3;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark Managing selection and highlight

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    return controller.flags & CKViewControllerFlagsSelectable;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{ }

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{ }

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    return controller.flags & CKViewControllerFlagsSelectable;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected addObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    [controller didSelect];
    
    if(!self.stickySelectionEnabled){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            
            //Cause didDeselectRowAtIndexPath is not called!
            NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
            [selected removeObject:indexPath];
            self.sectionContainer.selectedIndexPaths = selected;
        });
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
}

/*
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout{
    
}
*/

- (void)invalidateControllerAtIndexPath:(NSIndexPath*)indexPath{
    UICollectionViewLayoutInvalidationContext* context = [[[[[self.collectionViewLayout class] invalidationContextClass] alloc]init]autorelease];
    [context invalidateItemsAtIndexPaths:@[indexPath]];
    [self.collectionViewLayout invalidateLayoutWithContext:context];
}

#pragma mark Flow Layout Management


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self controllerAtIndexPath:indexPath];
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


#pragma mark Managing Scrolling

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrolling = YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    [self fetchMoreData];
    
    self.scrolling = NO;
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)fetchMoreData{
    NSMutableIndexSet* sectionsIndexes = [NSMutableIndexSet indexSet];
    NSMutableDictionary* lastRowForSections = [NSMutableDictionary dictionary];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        NSInteger section = indexPath.section;
        [sectionsIndexes addIndex:indexPath.section];
        
        NSNumber* lastRow = [lastRowForSections objectForKey:@(section)];
        if(lastRow){
            if([lastRow integerValue] < indexPath.row){
                [lastRowForSections setObject:@(indexPath.row) forKey:@(section)];
            }
        }else{
            [lastRowForSections setObject:@(indexPath.row) forKey:@(section)];
        }
    }
    
    if(lastRowForSections.count == 0){
        for(CKSection* section in self.sectionContainer.sections){
            if([section isKindOfClass:[CKCollectionSection class]]){
                [sectionsIndexes addIndex:section.sectionIndex];
                [lastRowForSections setObject:@(0) forKey:@(section.sectionIndex)];
            }
        }
    }
    
    for(NSNumber* section in [lastRowForSections allKeys]){
        NSNumber* row = [lastRowForSections objectForKey:section];
        
        CKAbstractSection* abstractSection = [self sectionAtIndex:[section integerValue]];
        [abstractSection fetchNextPageFromIndex:[row integerValue]];
    }
}



/* Forwarding calls to section container
 */

- (NSInteger)indexOfSection:(CKAbstractSection*)section{
    return [self.sectionContainer indexOfSection:section];
}

- (NSIndexSet*)indexesOfSections:(NSArray*)sections{
    return [self.sectionContainer indexesOfSections:sections];
}

- (id)sectionAtIndex:(NSInteger)index{
    return [self.sectionContainer sectionAtIndex:index];
}

- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes{
    return [self.sectionContainer sectionsAtIndexes:indexes];
}

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer addSection:section animated:animated];
}

- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer insertSection:section atIndex:index animated:animated];
}

- (void)addSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer addSections:sections animated:animated];
}

- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer insertSections:sections atIndexes:indexes animated:animated];
}

- (void)removeAllSectionsAnimated:(BOOL)animated{
    [self.sectionContainer removeAllSectionsAnimated:animated];
}

- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer removeSection:section animated:animated];
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer removeSectionAtIndex:index animated:animated];
}

- (void)removeSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer removeSections:sections animated:animated];
}

- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer removeSectionsAtIndexes:indexes animated:animated];
}

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath{
    return [self.sectionContainer controllerAtIndexPath:indexPath];
}

- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths{
    return [self.sectionContainer controllersAtIndexPaths:indexPaths];
}

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller{
    return [self.sectionContainer indexPathForController:controller];
}

- (NSArray*)indexPathsForControllers:(NSArray*)controllers{
    return [self.sectionContainer indexPathsForControllers:controllers];
}

- (void)setSelectedIndexPaths:(NSArray*)selectedIndexPaths{
    self.sectionContainer.selectedIndexPaths = selectedIndexPaths;
}

- (NSArray*)selectedIndexPaths{
    return self.sectionContainer.selectedIndexPaths;
}


@end



@implementation CKReusableViewController(CKCollectionViewController)
@dynamic collectionViewCell;

- (UICollectionViewCell*)collectionViewCell{
    if([self.contentViewCell isKindOfClass:[UICollectionViewCell class]])
        return (UICollectionViewCell*)self.contentViewCell;
    return nil;
}

@end