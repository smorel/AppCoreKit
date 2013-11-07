//
//  CKCollectionViewPageLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewPageLayout.h"

@implementation CKCollectionViewPageLayout

- (id)init{
    self = [super init];
    self.margins = 0;
    self.insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    NSIndexPath* index = [self indexPathForViewOfInterest];
    
     CGFloat offset = (fabs(velocity.x) < 0.5) ? 0 : ((velocity.x < 0.0f) ? -1 : 1);
     
     CGFloat newSelectedItem = index.item + offset;
     if(newSelectedItem < 0){
         newSelectedItem = 0;
     }else if(newSelectedItem >= [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0]){
         newSelectedItem = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0] - 1;
     }
     
     UICollectionViewLayoutAttributes* attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:newSelectedItem inSection:0]];
     return CGPointMake(attributes.frame.origin.x - self.margins, attributes.frame.origin.y);
}

- (CGRect)frameForViewAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger index = indexPath.item;
    return CGRectMake(self.insets.left + self.margins + (index * (self.collectionView.bounds.size.width - (self.insets.left + self.insets.right) - (2*self.margins))),
                      self.insets.top,
                      (self.collectionView.bounds.size.width - (self.insets.left + self.insets.right) - (2*self.margins)),
                      self.collectionView.bounds.size.height - self.insets.bottom);
}

- (CGSize)collectionViewContentSize{
    return CGSizeMake( (self.insets.left + self.insets.right) + (self.collectionView.bounds.size.width  - (2*self.margins))  * ([self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0]) + (2*self.margins),
                      self.collectionView.bounds.size.height);
}

- (CGPoint)contentOffsetForViewAtIndexPath:(NSIndexPath*)indexPath{
    return CGPointMake((self.insets.left + self.insets.right)  + (indexPath.item * (self.collectionView.bounds.size.width - (2*self.margins))), self.insets.top);
}

- (NSIndexPath*)indexPathForViewOfInterest{
    CGPoint point = CGPointMake(self.insets.left + self.collectionView.contentOffset.x + self.margins + ((self.collectionView.bounds.size.width - (2*self.margins)) / 2),
                                self.collectionView.contentOffset.y + self.insets.top );
    
    NSIndexPath* index = [self indexPathForViewAtPoint:point];
    return index;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}

@end
