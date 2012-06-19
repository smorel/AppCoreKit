//
//  UIView+LayoutHelper.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIView+LayoutHelper.h"
#import "CKBinding.h"
#import <objc/runtime.h>

static char UIViewLayoutHelperPreferedSizeKey;
static char UIViewLayoutHelperMinimumSizeKey;
static char UIViewLayoutHelperMaximumSizeKey;
static char UIViewLayoutHelperLayoutManagerKey;

@implementation UIView (LayoutHelper)

@dynamic bounds, subviews;

- (void)setLayoutManager:(id<CKLayoutManager>)aLayoutManager {
    objc_setAssociatedObject(self, &UIViewLayoutHelperLayoutManagerKey, aLayoutManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    aLayoutManager.layoutContainer = self;
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [self bind:@"frame" executeBlockImmediatly:NO withBlock:^(id value) {
        [self setNeedsAutomaticLayout];
    }];
    [self endBindingsContext];
}

- (id<CKLayoutManager>)layoutManager {
    return objc_getAssociatedObject(self, &UIViewLayoutHelperLayoutManagerKey);
}

- (void)setNeedsAutomaticLayout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performLayout) object:nil]; //Perform the layout only once at the end of the runloop
    [self performSelector:@selector(performLayout)];
}

- (void)performLayout {
    [self.layoutManager layout];
}

#pragma mark - Size

- (CGSize)preferedSize {
    NSValue *preferedSize = objc_getAssociatedObject(self, &UIViewLayoutHelperPreferedSizeKey);
    if (preferedSize)
        return [preferedSize CGSizeValue];
    
    if ([self conformsToProtocol:@protocol(CKLayoutContainer)]) {
        id <CKLayoutManager> manager = [(id<CKLayoutContainer>) self layoutManager];
        if (manager) {
            if ([manager respondsToSelector:@selector(preferedSize)])
                return manager.preferedSize;
        }
    }
    
    return self.bounds.size;
}

- (void)setPreferedSize:(CGSize)preferedSize {
    objc_setAssociatedObject(self, &UIViewLayoutHelperPreferedSizeKey, [NSValue valueWithCGSize:preferedSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)minimumSize {
    NSValue *minSize = objc_getAssociatedObject(self, &UIViewLayoutHelperMinimumSizeKey);
    if (minSize)
        return [minSize CGSizeValue];
    
    if ([self conformsToProtocol:@protocol(CKLayoutContainer)]) {
        id <CKLayoutManager> manager = [(id<CKLayoutContainer>) self layoutManager];
        if (manager) {
            if ([manager respondsToSelector:@selector(minimumSize)])
                return manager.minimumSize;
        }
    }
    
    return self.preferedSize;
}

- (void)setMinimumSize:(CGSize)minimumSize {
    objc_setAssociatedObject(self, &UIViewLayoutHelperMinimumSizeKey, [NSValue valueWithCGSize:minimumSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)maximumSize {
    NSValue *maxSize = objc_getAssociatedObject(self, &UIViewLayoutHelperMaximumSizeKey);
    if (maxSize)
        return [maxSize CGSizeValue];
    
    if ([self conformsToProtocol:@protocol(CKLayoutContainer)]) {
        id <CKLayoutManager> manager = [(id<CKLayoutContainer>) self layoutManager];
        if (manager) {
            if ([manager respondsToSelector:@selector(maximumSize)])
                return manager.maximumSize;
        }
    }
    
    return self.preferedSize;
}

- (void)setMaximumSize:(CGSize)maximumSize {
    objc_setAssociatedObject(self, &UIViewLayoutHelperMaximumSizeKey, [NSValue valueWithCGSize:maximumSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
