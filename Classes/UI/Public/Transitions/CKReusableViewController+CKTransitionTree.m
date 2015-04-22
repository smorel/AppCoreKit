//
//  CKReusableViewController+CKTransitionTree.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKReusableViewController+CKTransitionTree.h"

@implementation CKReusableViewController(CKTransitionTree)

- (UIView*)provideTemporaryViewForTransitionWithIndexPath:(NSIndexPath*)indexPath
                                     collectionViewLayout:(UICollectionViewLayout*)collectionViewLayout{
    if([self isViewLoaded])
        return self.view;
    
    UICollectionViewLayoutAttributes* attr = [collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    UIView* tocell = [[[UIView alloc]initWithFrame:attr.frame]autorelease];
    
    
    [self prepareForReuseUsingContentView:tocell contentViewCell:tocell];
    
    [self viewDidLoad];
    [self viewWillAppear:NO];
    
    [self preferredSizeConstraintToSize:attr.frame.size];
    [self.view layoutSubviews];
    
    [self viewDidAppear:NO];
    
    return tocell;
}

@end