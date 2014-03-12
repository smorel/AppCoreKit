//
//  CKCollectionViewCell.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-22.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKCollectionViewCell : UICollectionViewCell

- (UICollectionView*)parentCollectionView;

- (CGSize)preferredSizeConstraintToSize:(CGSize)size;

@end
