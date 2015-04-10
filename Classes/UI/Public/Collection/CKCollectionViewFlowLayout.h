//
//  CKCollectionViewPageLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewLayout.h"

/**
 */
@protocol CKCollectionViewFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath *)indexPath;

@end


/**
 */
@interface CKCollectionViewFlowLayout : UICollectionViewFlowLayout

@end
