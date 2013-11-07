//
//  CKCollectionViewLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CKCollectionViewLayoutOrientation) {
	CKCollectionViewLayoutOrientationVertical,
	CKCollectionViewLayoutOrientationHorizontal
};

@interface CKCollectionViewLayout : UICollectionViewLayout

@property(nonatomic,assign) UICollectionViewLayout* parentCollectionViewLayout;

/** Implementing this method is requiered. Return [0,0,0,0] by default.
 */
- (CGRect)frameForViewAtIndexPath:(NSIndexPath*)indexPath;

/** Implementing this method is requiered.
 */
- (CGSize)collectionViewContentSize;

/** Implementing this method is optional. The default implementation iterates on sections and items and returns the index path of the item who's frame intersect the point.
 */
- (NSIndexPath*)indexPathForViewAtPoint:(CGPoint)point;

/** Implementing this method is optional. Return origin of the frame for item at the specified index path by default.
 */
- (CGPoint)contentOffsetForViewAtIndexPath:(NSIndexPath*)indexPath;

/** Implements this method if you have custom paging.
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity;

/** 
 */
- (NSIndexPath*)indexPathForViewOfInterest;

/** TODO : Integrates dynamics
 */

@end
