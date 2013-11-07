//
//  CKCollectionViewGridLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewGridLayout.h"
#import "NSObject+Bindings.h"

@interface NSIndexPath (CKCollectionViewGridLayout)

+ (NSIndexPath*)indexPathForGridPage:(NSUInteger)page row:(NSUInteger)row cell:(NSUInteger)cell;

@property(nonatomic,assign,readonly) NSUInteger gridPage;
@property(nonatomic,assign,readonly) NSUInteger gridRow;
@property(nonatomic,assign,readonly) NSUInteger gridCell;

@end

@implementation NSIndexPath (CKCollectionViewGridLayout)


+ (NSIndexPath*)indexPathForGridPage:(NSUInteger)page row:(NSUInteger)row cell:(NSUInteger)cell{
    const NSUInteger indexes[3] = { page, row, cell};
    NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:&indexes[0] length:3];
    return indexPath;
}

- (NSUInteger)gridPage{
    return [self indexAtPosition:0];
}

- (NSUInteger)gridRow{
    return [self indexAtPosition:1];
}

- (NSUInteger)gridCell{
    return [self indexAtPosition:2];
}

@end


@interface CKCollectionViewGridLayout()
@property(nonatomic,assign) CGPoint contentOffsetToReachAfterBoundsChange;
@end

@implementation CKCollectionViewGridLayout

- (void)dealloc{
    [self clearBindingsContext];
    
    [_pages release];
    
    [super dealloc];
}

#pragma mark Index Management

- (NSInteger)numberOfViewsInPage:(NSInteger)pageIndex{
    NSArray* page = [self.pages objectAtIndex:pageIndex];
    NSInteger count = 0;
    for(NSArray* ar in page){
        for(NSNumber* n in ar){
            ++count;
        }
    }
    return count;
}

- (NSInteger)numberOfRowsInPage:(NSInteger)pageIndex{
    NSArray* page = [self.pages objectAtIndex:pageIndex];
    NSInteger count = 0;
    for(NSArray* ar in page){
        ++count;
    }
    return count;
}

- (NSInteger)numberOfViewInAllPages{
    NSInteger count = 0;
    for(NSArray* page in self.pages){
        for(NSArray* ar in page){
            for(NSNumber* n in ar){
                ++count;
            }
        }
    }
    return count;
}

- (NSIndexPath*)gridIndexPathForViewAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger pageModulo = floorf((indexPath.item / (CGFloat)[self numberOfViewInAllPages]));
    NSInteger indexInPageModulo = indexPath.item - (pageModulo * [self numberOfViewInAllPages]);

    NSInteger count = 0;
    for(int pageIndex =0;pageIndex<self.pages.count;++pageIndex){
        NSInteger numberOfViewsInPage = [self numberOfViewsInPage:pageIndex];
        if(indexInPageModulo < (count + numberOfViewsInPage)){
            NSInteger indexInPage = indexInPageModulo - count;
            
            NSInteger countInPage = 0;
            NSArray* page = [self.pages objectAtIndex:pageIndex];
            for(NSInteger rowIndex =0; rowIndex < page.count; ++rowIndex){
                NSArray* row = [page objectAtIndex:rowIndex];
                for(NSInteger cellIndex = 0; cellIndex < row.count; ++cellIndex){
                    if(countInPage == indexInPage){
                        return [NSIndexPath indexPathForGridPage:((pageModulo * self.pages.count) + pageIndex) row:rowIndex cell:cellIndex];
                    }
                    ++countInPage;
                }
            }
            
            break;
        }
        count += numberOfViewsInPage;
    }
    
    return nil;
}

- (CGFloat)percentOccupationForCellWithGridIndexPath:(NSIndexPath*)indexPath{
    NSArray* row = [self rowForCellWithGridIndexPath:indexPath];
    CGFloat occupation = [[row objectAtIndex:indexPath.gridCell]floatValue];
    return occupation;
}

- (NSArray*)rowForCellWithGridIndexPath:(NSIndexPath*)indexPath{
    NSInteger pageModulo = indexPath.gridPage / self.pages.count;
    NSInteger pageIndex = indexPath.gridPage - (pageModulo * self.pages.count);
    
    NSArray* page = [self.pages objectAtIndex:pageIndex];
    NSArray* row = [page objectAtIndex:indexPath.gridRow];
    return row;
}

- (NSInteger)numberOfRowsInPageForCellWithGridIndexPath:(NSIndexPath*)indexPath{
    NSInteger pageModulo = indexPath.gridPage / self.pages.count;
    NSInteger pageIndex = indexPath.gridPage - (pageModulo * self.pages.count);
    
    NSArray* page = [self.pages objectAtIndex:pageIndex];
    return page.count;
}

- (NSInteger)requieredNumberOfPages{
    CGFloat numberOfViews = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    if(numberOfViews == 0)
        return 0;
    
    NSIndexPath* gridIndexPath = [self gridIndexPathForViewAtIndexPath:[NSIndexPath indexPathForRow:(numberOfViews - 1) inSection:0]];
    /*
    NSInteger pageModulo = gridIndexPath.gridPage / self.pages.count;
    NSInteger pageIndex = gridIndexPath.gridPage - (pageModulo * self.pages.count);
    
    
    NSInteger numberOfViewInPage = [self numberOfViewsInPage:pageIndex];
    
    BOOL stop = NO;
    NSInteger indexInPage = 0;
    NSArray* page = [self.pages objectAtIndex:pageIndex];
    for(NSInteger rowIndex = 0; rowIndex < page.count && !stop; ++rowIndex){
        NSArray* row = [page objectAtIndex:rowIndex];
        for(NSInteger cellIndex = 0; cellIndex < row.count && !stop; ++cellIndex){
            if(gridIndexPath.gridRow == rowIndex && gridIndexPath.gridCell == cellIndex) {stop = YES; break;}
            ++indexInPage;
        }
    }*/
    
    
    return (gridIndexPath.gridPage + 1);
}

#pragma Layout Management

- (CGRect)frameForViewAtIndexPath:(NSIndexPath*)indexPath{
    NSIndexPath* gridIndexPath = [self gridIndexPathForViewAtIndexPath:indexPath];
    
    NSInteger numberOfRowsInPage = [self numberOfRowsInPageForCellWithGridIndexPath:gridIndexPath];
    CGFloat   percentOccupation  = [self percentOccupationForCellWithGridIndexPath:gridIndexPath];
    
    CGFloat rowHeight = (self.collectionView.bounds.size.height  - self.verticalSpace) / numberOfRowsInPage;
    CGSize size = CGSizeMake((self.collectionView.bounds.size.width  - self.horizontalSpace)* percentOccupation,rowHeight);
    
    
    NSArray* row = [self rowForCellWithGridIndexPath:gridIndexPath];
    
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            CGFloat x = (self.horizontalSpace / 2);
            for(int i =0; i < gridIndexPath.gridCell; ++i){
                CGFloat occupation = [[row objectAtIndex:i]floatValue];
                x += (self.collectionView.bounds.size.width   - self.horizontalSpace) * occupation;
            }
            
            CGFloat y = (self.verticalSpace / 2) + (gridIndexPath.gridPage * self.collectionView.bounds.size.height) + (gridIndexPath.gridRow * rowHeight);
            
            return CGRectIntegral(CGRectMake(x + (self.horizontalSpace / 2), y + (self.verticalSpace / 2), size.width - self.horizontalSpace, size.height - self.verticalSpace));
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            CGFloat x = (self.horizontalSpace / 2) + ((gridIndexPath.gridPage * self.collectionView.bounds.size.width));
            for(int i =0; i < gridIndexPath.gridCell; ++i){
                CGFloat occupation = [[row objectAtIndex:i]floatValue];
                x += (self.collectionView.bounds.size.width  - self.horizontalSpace) * occupation;
            }
            
            CGFloat y = (self.verticalSpace / 2) + (gridIndexPath.gridRow * rowHeight);
            
            return CGRectIntegral(CGRectMake(x + (self.horizontalSpace / 2), y + (self.verticalSpace / 2), size.width - self.horizontalSpace, size.height - self.verticalSpace));
        }
    }
    
    return CGRectMake(0, 0, 0, 0);
}

- (CGSize)collectionViewContentSize{
    NSInteger numberOfPages = [self requieredNumberOfPages];
    
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            return CGSizeMake(self.collectionView.bounds.size.width,numberOfPages * self.collectionView.bounds.size.height);
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            return CGSizeMake(numberOfPages * self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
        }
    }

    return CGSizeMake(0,0);
}

- (CGPoint)contentOffsetForViewAtIndexPath:(NSIndexPath*)indexPath{
    NSIndexPath* gridIndexPath = [self gridIndexPathForViewAtIndexPath:indexPath];
    
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            return CGPointMake(0,gridIndexPath.gridPage * self.collectionView.bounds.size.height);
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            return CGPointMake(gridIndexPath.gridPage * self.collectionView.bounds.size.width,0);
        }
    }
    
    return CGPointMake(0,0);
}

- (NSIndexPath*)indexPathForViewAtPoint:(CGPoint)point{
    NSInteger numberOfSections = 1;
    if([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
        numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    
    for(int section = 0; section < numberOfSections; ++section){
        for(int item =0;item<[self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];++item){
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGRect frame = [self frameForViewAtIndexPath:indexPath];
            CGRect frameWithSpacings = CGRectMake(frame.origin.x - (self.horizontalSpace / 2),
                                                  frame.origin.y - (self.verticalSpace / 2),
                                                  frame.size.width + self.horizontalSpace,
                                                  frame.size.height + self.verticalSpace);
            if(CGRectContainsPoint(frameWithSpacings, point)){
                return indexPath;
            }
        }
    }
    return nil;
}

- (NSIndexPath*)indexPathForViewOfInterest{
    CGPoint point = CGPointMake(self.collectionView.contentOffset.x + (self.horizontalSpace / 2),
                                self.collectionView.contentOffset.y + (self.verticalSpace / 2));
    
    NSIndexPath* index = [self indexPathForViewAtPoint:point];
    return index;
}

#pragma Paging Management

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    if(!self.pagingEnabled){
        return proposedContentOffset;
    }
    
    NSIndexPath* index = [self indexPathForViewOfInterest];
    NSIndexPath* gridIndexPath = [self gridIndexPathForViewAtIndexPath:index];
    
    CGFloat offset;
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            offset = (fabs(velocity.y) < 0.5) ? 0 : ((velocity.y < 0.0f) ? 0 : 1);
            break;
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            offset = (fabs(velocity.x) < 0.5) ? 0 : ((velocity.x < 0.0f) ? 0 : 1);
            break;
        }
    }
    
    NSInteger numberOfPages= [ self requieredNumberOfPages];
    
    CGFloat newSelectedPage = gridIndexPath.gridPage + offset;
    if(newSelectedPage < 0){
        newSelectedPage = 0;
    }else if(newSelectedPage >= numberOfPages){
        newSelectedPage = numberOfPages - 1;
    }
    
    CGPoint newOffset;
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            newOffset = CGPointMake(0,newSelectedPage * self.collectionView.bounds.size.height);
            break;
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            newOffset = CGPointMake(newSelectedPage * self.collectionView.bounds.size.width,0);
            break;
        }
    }
    
    return newOffset;
}

- (void)setHorizontalSpace:(NSInteger)s{
    _horizontalSpace = s;
    [self invalidateLayout];
}

- (void)setVerticalSpace:(NSInteger)s{
    _verticalSpace = s;
    [self invalidateLayout];
}

- (void)setOrientation:(CKCollectionViewLayoutOrientation)o{
    NSInteger page = 0;
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            page = floorf(self.collectionView.contentOffset.y / self.collectionView.bounds.size.height);
            break;
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            page = floorf(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
            break;
        }
    }
    
    _orientation = o;
    
    [self invalidateLayout];
    [self.collectionView layoutSubviews];
    
    CGPoint newOffset;
    switch(self.orientation){
        case CKCollectionViewLayoutOrientationVertical:{
            newOffset = CGPointMake(0, page * self.collectionView.bounds.size.height);
            break;
        }
        case CKCollectionViewLayoutOrientationHorizontal:{
            newOffset = CGPointMake(page  * self.collectionView.bounds.size.width,0);
            break;
        }
    }
    self.collectionView.contentOffset = newOffset;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    return proposedContentOffset;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}

- (void)prepareLayout{
    [super prepareLayout];
    
  //  [self beginBindingsContextByRemovingPreviousBindings];
   // [self.collectionView bind:@"frame" withBlock:^(id value) {
   //     [self invalidateLayout];
   // }];
   // [self endBindingsContext];
}

@end
