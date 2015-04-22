//
//  CKReusableViewController+CKTransitionTree.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKReusableViewController.h"

@interface CKReusableViewController(CKTransitionTree)

- (UIView*)provideTemporaryViewForTransitionWithIndexPath:(NSIndexPath*)indexPath
                                     collectionViewLayout:(UICollectionViewLayout*)collectionViewLayout;

@end