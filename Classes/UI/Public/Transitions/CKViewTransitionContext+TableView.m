//
//  CKViewTransitionContext+TableView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-22.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext+TableView.h"

@implementation CKViewTransitionContext (TableView)

+ (UICollectionViewLayoutAttributes*)attributesForIndexPath:(NSIndexPath*)indexPath
                                                  tableView:(UITableView*)tableView
                                          transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    UICollectionViewLayoutAttributes* att = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    att.frame = [tableView convertRect:frame toView:[transitionContext containerView]];
    att.alpha = 1.0f;
    att.transform = CGAffineTransformIdentity;
    return att;
}

+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                            tableView:(UITableView*)tableView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                            animation:(CKViewTransitionContextAnimation)animation
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    
    context.snapshot = [CKViewTransitionContext snapshotView:cell withLayerAttributesAfterUpdate:YES];
    if(context.snapshot == nil){
        return nil;
    }
    context.snapshot.layer.zPosition = zPosition;
    
    context.startAttributes = [self attributesForIndexPath:sourceIndexPath tableView:tableView transitionContext:transitionContext];
    context.endAttributes = [self attributesFromAttributes:context.startAttributes animation:animation transitionContext:transitionContext];
    
    return context;
}

+ (CKViewTransitionContext*)contextForSourceIndexPath:(NSIndexPath*)sourceIndexPath
                                            tableView:(UITableView*)tableView
                                                 cell:(UIView*)cell
                                            zPosition:(CGFloat)zPosition
                                    transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    return [self contextForSourceIndexPath:sourceIndexPath tableView:tableView cell:cell zPosition:zPosition animation:CKViewTransitionContextAnimationNone transitionContext:transitionContext];
}

@end
