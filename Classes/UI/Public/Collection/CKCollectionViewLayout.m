//
//  CKCollectionViewLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewLayout.h"

//TODO : replace indexPathToLayoutAttributes by a hash map for speed up !

@interface CKCollectionViewLayout()
@property(nonatomic,retain) NSMutableDictionary* indexPathToLayoutAttributes;
@property(nonatomic,assign) NSInteger lastNumberOfObjects;
@property(nonatomic,assign) CGSize lastCollectionViewSize;
@end

@implementation CKCollectionViewLayout

- (id)init{
    self = [super init];
    self.lastNumberOfObjects = -1;
    return self;
}

- (void)dealloc{
    [_indexPathToLayoutAttributes release];
    
    [super dealloc];
}

- (CGRect)frameForViewAtIndexPath:(NSIndexPath*)indexPath{
    return CGRectMake(0,0,0,0);
}

- (CGSize)collectionViewContentSize{
    return CGSizeMake(0,0);
}


- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems{
}

- (NSInteger)numberOfItems {
    NSInteger count = 0;
    if([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
        NSInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
        for(int i =0; i< numberOfSections;++i){
            count += [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:i];
        }
    }
    return count;
}

- (void)prepareLayout{
    NSInteger count = [self numberOfItems];
    if(count == self.lastNumberOfObjects && CGSizeEqualToSize(self.lastCollectionViewSize, self.collectionView.frame.size))
        return;
    
    self.lastNumberOfObjects = count;
    self.lastCollectionViewSize = self.collectionView.frame.size;
    self.indexPathToLayoutAttributes = [NSMutableDictionary dictionary];
    
    NSInteger numberOfSections = 1;
    if([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
        numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    
    for(int section = 0; section < numberOfSections; ++section){
        for(int item =0;item<[self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];++item){
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGRect frame = [self frameForViewAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes *attributes =  [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = frame;

            [self.indexPathToLayoutAttributes setObject:attributes forKey:indexPath];
        }
    }
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath{
    return [self.indexPathToLayoutAttributes objectForKey:indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray* array = [NSMutableArray array];
    
    NSIndexPath* indexPathOfInterest = [self indexPathForViewOfInterest];
    for(NSIndexPath* indexPath in [self.indexPathToLayoutAttributes allKeys]){
        UICollectionViewLayoutAttributes* attributes = [self.indexPathToLayoutAttributes objectForKey:indexPath];
        if(CGRectIntersectsRect(rect, attributes.frame)){
            attributes.zIndex = [indexPathOfInterest isEqual:indexPath] ? 10 : 0;// 999999 - [self distanceBetweenIndexPath:indexPathOfInterest target:indexPath];
            [array addObject:attributes];
        }
    }
    
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    //this is called when scrolling !!!!!!!!!!!!!!!!!
	return NO;
}

/*
- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds{
}

- (void)finalizeAnimatedBoundsChange{
    
}
 */

- (NSIndexPath*)indexPathForViewAtPoint:(CGPoint)point{
    NSInteger numberOfSections = 1;
    if([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
        numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    
    for(int section = 0; section < numberOfSections; ++section){
        for(int item =0;item<[self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];++item){
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGRect frame = [self frameForViewAtIndexPath:indexPath];
            if(CGRectContainsPoint(frame, point)){
                return indexPath;
            }
        }
    }
    return nil;
}

- (CGPoint)contentOffsetForViewAtIndexPath:(NSIndexPath*)indexPath{
    CGRect frame = [self frameForViewAtIndexPath:indexPath];
    return frame.origin;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    return proposedContentOffset;
}

- (UICollectionView*)collectionView{
    if(self.parentCollectionViewLayout == nil){
        return [super collectionView];
    }
    return self.parentCollectionViewLayout.collectionView;
}

- (NSIndexPath*)indexPathForViewOfInterest{
    return nil;
}

- (void)invalidateLayout{
    if(self.parentCollectionViewLayout){
        [self.parentCollectionViewLayout invalidateLayout];
        return;
    }
    [super invalidateLayout];
}

@end
