//
//  CKViewTransitionContext+ViewHierarchy.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-21.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext.h"
#import "CKViewTransitionContext+Animation.h"

@interface CKViewTransitionContext (ViewHierarchy)

+ (CKViewTransitionContext*)contextForSubviewViewNamed:(NSString*)viewName
                                            sourceView:(UIView*)sourceView
                                            targetView:(UIView*)targetView;

+ (CKViewTransitionContext*)contextForView:(UIView*)view
                         transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

+ (CKViewTransitionContext*)contextForView:(UIView*)view
                                 animation:(CKViewTransitionContextAnimation)animation
                         transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

+ (CKViewTransitionContext*)contextForSubviewViewNamed:(NSString*)viewName
                                                  view:(UIView*)view;

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView
                                       targetView:(UIView*)targetView;

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView;

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView
                                       targetView:(UIView*)targetView
                            ignoringViewWithNames:(NSArray*)viewNames;

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView
                            ignoringViewWithNames:(NSArray*)viewNames;

@end
