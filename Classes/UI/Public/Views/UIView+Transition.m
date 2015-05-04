//
//  UIView+Transition.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIView+Transition.h"
#import "CKStyleView.h"
#import "CKHighlightView.h"
#import "CKShadowView.h"
#import "UIView+Name.h"
#import "UIView+Snapshot.h"
#import "NSObject+Bindings.h"
#import "CKProperty.h"

@implementation UIView (Transition)

+ (CKEffectView*)cloneEffectView:(CKEffectView*)other root:(UIView*)root{
    CGRect rect = [other.superview convertRect:other.frame toView:root];
    
    CKEffectView* effectView = [[other copy]autorelease];
    effectView.frame = rect;
    effectView.hidden = NO;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [effectView layoutSubviews];
    
    return effectView;
}

- (UIImage*)snapshotWithoutEffectViewsIncludingSubview:(BOOL)includingSubviews{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    NSArray* viewsToInclude = !includingSubviews ? [self viewsToIncludeInTransitionSnapshot] : nil;
    
    //- I don't like this cause it will invalidate layouts
    NSMutableArray* viewsToShow = [NSMutableArray array];
    if(!includingSubviews){
        for(UIView* v in self.subviews){
            if(![viewsToInclude containsObject:v]){
                if(!v.hidden){
                    [viewsToShow addObject:v];
                    v.hidden = YES;
                }
            }
        }
    }
    
    UIImage* result = [self snapshot];
    
    for(UIView* v in viewsToShow){
        v.hidden = NO;
    }
    
    return result;
}

- (NSArray*)viewsToIncludeInTransitionSnapshot{
    if(self.subviews.count <= 0)
        return nil;
    
    if([[self.subviews objectAtIndex:0]isKindOfClass:[CKStyleView class]])
        return @[[self.subviews objectAtIndex:0]];
    
    return nil;
}

+ (void)installEffectView:(CKEffectView*)effectView fromView:(UIView*)root inView:(UIView*)view name:(NSString*)name{
    CKEffectView* transitionEffectView = [[self class] cloneEffectView:effectView root:root];
    transitionEffectView.name = name;
    [view addSubview:transitionEffectView];
}

- (UIView*)transitionSnapshotWithoutViewHierarchy{
    [self layoutSubviews];
    
    [self setEffectViewsEnabled:NO];
    
    UIView* snapshot = [[[UIImageView alloc]initWithImage:[self snapshotWithoutEffectViewsIncludingSubview:NO]]autorelease];
    snapshot.frame = self.bounds;
    
    for(UIView* v in self.subviews){
        if([v isKindOfClass:[CKEffectView class]]){
            [[self class]installEffectView:(CKEffectView*)v fromView:self inView:snapshot name:self.name];
        }
    }
    
    [self setEffectViewsEnabled:YES];
    
    return snapshot;
}

- (UIView*)transitionSnapshotWithViewHierarchy{
    [self layoutSubviews];
    
    [self setEffectViewsEnabled:NO];
    
    UIView* snapshot = [[[UIImageView alloc]initWithImage:[self snapshotWithoutEffectViewsIncludingSubview:YES]]autorelease];
    snapshot.frame = self.bounds;
    
    //if there are styleviews with dynamic highlight or shadows embedded in the hierarchy, they are snapshot instead of cloned with live update !
    [self installEffectViewsFromView:self inView:snapshot];
    
    [self setEffectViewsEnabled:YES];
    
    return snapshot;
}

- (void)installEffectViewsFromView:(UIView*)root inView:(UIView*)view{
    for(UIView* v in self.subviews){
        if([v isKindOfClass:[CKEffectView class]]){
            [[self class]installEffectView:(CKEffectView*)v fromView:root inView:view name:self.name];
        }
    }
    
    for(UIView* subview in self.subviews){
        [subview installEffectViewsFromView:root inView:view];
    }
}


- (void)setEffectViewsEnabled:(BOOL)enabled{
    for(UIView* v in self.subviews){
        if([v isKindOfClass:[CKEffectView class]]){
            v.hidden = !enabled;
        }
    }
    
    for(UIView* subview in self.subviews){
        [subview setEffectViewsEnabled:enabled];
    }
}

@end
