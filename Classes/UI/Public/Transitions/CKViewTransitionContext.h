//
//  CKViewTransitionContext.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-20.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,CKViewTransitionContextVisibility){
    CKViewTransitionContextVisibilityDuringAnimation = 1 << 1,
    CKViewTransitionContextVisibilityBeforeAnimation = 1 << 2,
    CKViewTransitionContextVisibilityAfterAnimation  = 1 << 3,
    CKViewTransitionContextVisibilityNever = 0,
    CKViewTransitionContextVisibilityAlways = CKViewTransitionContextVisibilityDuringAnimation | CKViewTransitionContextVisibilityBeforeAnimation | CKViewTransitionContextVisibilityAfterAnimation
};


@interface CKViewTransitionContext : NSObject

@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) UIView* snapshot;
@property(nonatomic,assign) CKViewTransitionContextVisibility visibility;
@property(nonatomic,retain) UICollectionViewLayoutAttributes* startAttributes;
@property(nonatomic,retain) UICollectionViewLayoutAttributes* endAttributes;
@property(nonatomic,retain,readonly) NSArray* viewTransitionContexts;

- (CKViewTransitionContext*)reverseContext;

- (void)addTransitionContext:(CKViewTransitionContext*)context;
- (void)addTransitionContexts:(NSArray*)contexts;
- (CKViewTransitionContext*)viewTransitionContextNamed:(NSString*)name;
- (void)removeAllViewTransitionContextsRecursive:(BOOL)recursive;

+ (CKViewTransitionContext*)contextByReversingContext:(CKViewTransitionContext*)context;
+ (UIView*)snapshotView:(UIView*)view withHierarchy:(BOOL)withHierarchy context:(CKViewTransitionContext*)context;

@end