//
//  CKEffectView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKEffectView.h"
#import "CKSharedDisplayLink.h"
#import "CKRuntime.h"
#import <objc/runtime.h>

@interface CKEffectView()<CKSharedDisplayLinkDelegate>
@property(nonatomic,assign)CGRect lastFrameInWindow;
@end

@implementation CKEffectView

- (void)dealloc {
    [CKSharedDisplayLink unregisterHandler:self];
    [super dealloc];
}

- (void)setNeedsEffectUpdate{
    self.lastFrameInWindow = CGRectZero;
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if(newWindow == nil){
        [CKSharedDisplayLink unregisterHandler:self];
        [self didUnregisterForUpdates];
    }
}

- (void)didMoveToWindow{
    [CKSharedDisplayLink registerHandler:self];
    [self didRegisterForUpdates];
}

- (CGRect)rectInWindow{
    CGRect rect = CGRectZero;
    CALayer* prez = self.layer.presentationLayer;
    if(prez){
        rect = [prez.superlayer convertRect:prez.frame toLayer:self.window.layer.presentationLayer];
    }else{
        rect = [self.superview convertRect:self.frame toView:self.window];
    }
    return rect;
}

- (void)sharedDisplayLinkDidRefresh:(CKSharedDisplayLink*)displayLink{
    CGRect rect = [self rectInWindow];
    if(CGRectEqualToRect(rect, self.lastFrameInWindow))
        return;
    
    self.lastFrameInWindow = rect;
    
    [self updateEffectWithRect:rect];
}


- (void)didRegisterForUpdates{
    
}

- (void)didUnregisterForUpdates{
    
}

- (void)updateEffectWithRect:(CGRect)rect{
    
}

- (void)superViewDidModifySubviewHierarchy{
    
}

- (void)updateEffect{
    CGRect rect = [self rectInWindow];
    [self updateEffectWithRect:rect];
}

+ (void)load{
    CKSwizzleSelector([UIView class], @selector(addSubview:), @selector(CKHighlightView_addSubview:));
    CKSwizzleSelector([UIView class], @selector(insertSubview:atIndex:), @selector(CKHighlightView_insertSubview:atIndex:));
    CKSwizzleSelector([UIView class], @selector(insertSubview:belowSubview:), @selector(CKHighlightView_insertSubview:belowSubview:));
    CKSwizzleSelector([UIView class], @selector(insertSubview:aboveSubview:), @selector(CKHighlightView_insertSubview:aboveSubview:));
}


@end


/**
 */
@interface UIView(CKEffectView)
@end

@implementation  UIView(CKEffectView)

static char UIViewNeedsToNotifyEffectViewsOfHierarchyChangesKey;

- (void)setNeedsToNotifyEffectViewsOfHierarchyChanges:(BOOL)bo{
    objc_setAssociatedObject(self, &UIViewNeedsToNotifyEffectViewsOfHierarchyChangesKey, @(bo), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)needsToNotifyEffectViewsOfHierarchyChanges{
    id v = objc_getAssociatedObject(self, &UIViewNeedsToNotifyEffectViewsOfHierarchyChangesKey);
    return v ? [v boolValue] : NO;
}

- (void)notifyEffectViewsOfHierarchyChanges{
    if(![self needsToNotifyEffectViewsOfHierarchyChanges])
        return;
    
    NSArray* subViews = [NSArray arrayWithArray:self.subviews];
    for(UIView* view in subViews){
        if([view isKindOfClass:[CKEffectView class]]){
            [(CKEffectView*)view superViewDidModifySubviewHierarchy];
        }
    }
}

- (void)CKHighlightView_insertSubview:(UIView *)view atIndex:(NSInteger)index{
    [self CKHighlightView_insertSubview:view atIndex:index];
    
    if([view isKindOfClass:[CKEffectView class]]){
        [self setNeedsToNotifyEffectViewsOfHierarchyChanges:YES];
    }
    
    [self notifyEffectViewsOfHierarchyChanges];
    
    // if([self highlightView]){
    //     [self bringSubviewToFront:[self highlightView]];
    // }
}

- (void)CKHighlightView_insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview{
    [self CKHighlightView_insertSubview:view belowSubview:siblingSubview];
    
    if([view isKindOfClass:[CKEffectView class]]){
        [self setNeedsToNotifyEffectViewsOfHierarchyChanges:YES];
    }
    
    [self notifyEffectViewsOfHierarchyChanges];
}

- (void)CKHighlightView_insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview{
    [self CKHighlightView_insertSubview:view aboveSubview:siblingSubview];
    
    if([view isKindOfClass:[CKEffectView class]]){
        [self setNeedsToNotifyEffectViewsOfHierarchyChanges:YES];
    }
    
    [self notifyEffectViewsOfHierarchyChanges];
}

- (void)CKHighlightView_addSubview:(UIView*)view{
    [self CKHighlightView_addSubview:view];
    
    if([view isKindOfClass:[CKEffectView class]]){
        [self setNeedsToNotifyEffectViewsOfHierarchyChanges:YES];
    }
    
    [self notifyEffectViewsOfHierarchyChanges];
}

@end

