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
#import "CKShadeView.h"
#import "UIView+Name.h"
#import "UIView+Snapshot.h"
#import "NSObject+Bindings.h"
#import "CKProperty.h"
#import "CKReplicantView.h"

@implementation UIView (Transition)

- (UIView*)transitionSnapshotWithoutViewHierarchy{
    [self layoutSubviews];
    
    UIView* snapshot = [[[CKReplicantView alloc]initWithView:self withoutSubviews:YES]autorelease];
    snapshot.frame = self.bounds;
    
    return snapshot;
}

- (UIView*)transitionSnapshotWithViewHierarchy{
    [self layoutSubviews];
    
    UIView* snapshot = [[[CKReplicantView alloc]initWithView:self withoutSubviews:NO]autorelease];
    snapshot.frame = self.bounds;

    return snapshot;
}

+ (void)installEffectView:(CKEffectView*)effectView fromView:(UIView*)root inView:(UIView*)view name:(NSString*)name{
    CKEffectView* transitionEffectView = [[self class] cloneEffectView:effectView root:root];
    transitionEffectView.name = name;
    [view addSubview:transitionEffectView];
}

+ (CKEffectView*)cloneEffectView:(CKEffectView*)other root:(UIView*)root{
    CGRect rect = [other.superview convertRect:other.frame toView:root];
    
    CKEffectView* effectView = [[other copy]autorelease];
    effectView.frame = rect;
    effectView.hidden = NO;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [effectView layoutSubviews];
    
    return effectView;
}

@end



@interface UICollectionViewCell (Transition)
@end


@implementation UICollectionViewCell (Transition)

- (UIView*)transitionSnapshotWithViewHierarchy{
    [self layoutSubviews];
    
    UIView* snapshot = [self.contentView snapshotViewAfterScreenUpdates:YES];
    snapshot.frame = self.bounds;
    
    for(UIView* v in self.subviews){
        if([v isKindOfClass:[CKEffectView class]]){
            [[self class]installEffectView:(CKEffectView*)v fromView:self inView:snapshot name:self.name];
        }
    }
    
    return snapshot;
}

- (UIView*)transitionSnapshotWithoutViewHierarchy{
    [self layoutSubviews];
    
    UIView* snapshot = [super transitionSnapshotWithoutViewHierarchy];
    
    for(UIView* v in self.subviews){
        if([v isKindOfClass:[CKEffectView class]]){
            [[self class]installEffectView:(CKEffectView*)v fromView:self inView:snapshot name:self.name];
        }
    }
    
    return snapshot;
}

@end

