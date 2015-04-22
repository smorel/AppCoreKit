//
//  CKViewTransitionContext+CollectionView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext+Animation.h"

@interface CKViewTransitionContext (CollectionView)

+ (UICollectionViewLayoutAttributes*)attributesForIndexPath:(NSIndexPath*)indexPath
                                                     layout:(UICollectionViewLayout*)layout
                                             collectionView:(UICollectionView*)collectionView
                                          transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;


//This will move a snapshot of cell from sourceIndexPath in sourceLayout to targetIndexPath in targetLayout
//sourceCollectionView && targetCollectionView are usefull to project layout frames into the transitionContext containerView window referential
//sourceLayout can differ than sourceCollectionView.collectionViewLayout and same for target. This is usefull to compute intermediate animation steps
+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                         sourceLayout:(UICollectionViewLayout*)sourceLayout
                                 sourceCollectionView:(UICollectionView*)sourceCollectionView
                                      targetIndexPath:(NSIndexPath*)targetIndexPath
                                         targetLayout:(UICollectionViewLayout*)targetLayout
                                 targetCollectionView:(UICollectionView*)targetCollectionView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;


+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                         sourceLayout:(UICollectionViewLayout*)sourceLayout
                                 sourceCollectionView:(UICollectionView*)sourceCollectionView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                            animation:(CKViewTransitionContextAnimation)animation
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                         sourceLayout:(UICollectionViewLayout*)sourceLayout
                                 sourceCollectionView:(UICollectionView*)sourceCollectionView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;


@end
