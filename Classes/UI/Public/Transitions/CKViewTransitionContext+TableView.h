//
//  CKViewTransitionContext+TableView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-22.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext+Animation.h"

@interface CKViewTransitionContext (TableView)

+ (UICollectionViewLayoutAttributes*)attributesForIndexPath:(NSIndexPath*)indexPath
                                                  tableView:(UITableView*)tableView
                                          transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;


+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                            tableView:(UITableView*)tableView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                            animation:(CKViewTransitionContextAnimation)animation
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                            tableView:(UITableView*)tableView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

@end
