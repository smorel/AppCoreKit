//
//  CKViewTransitionContext+ViewHierarchy.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-21.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext+ViewHierarchy.h"
#import "UIView+Name.h"
#import "UIView+Positioning.h"
#import "NSArray+Compare.h"

@interface CKViewTransitionContext()
@property(nonatomic,retain) NSArray* viewsToHideDuringTransition;
@end


@implementation CKViewTransitionContext (ViewHierarchy)

+ (void)adjustAttributes:(UICollectionViewLayoutAttributes*)attributes forSubView:(UIView*)subview inView:(UIView*)view{
    CGRect rect = [subview convertRect:subview.bounds toView:view];
    CGRect frame = attributes.frame;
    frame.origin.x += rect.origin.x;
    frame.origin.y += rect.origin.y;
    frame.size.width = rect.size.width;
    frame.size.height = rect.size.height;
    attributes.frame = frame;
}

+ (CKViewTransitionContext*)contextForSubviewViewNamed:(NSString*)viewName
                                            sourceView:(UIView*)sourceView
                                            targetView:(UIView*)targetView{
    
    UIView* sourceSubViewView  = [sourceView viewWithName:viewName];
    UIView* targetSubViewView  = [targetView viewWithName:viewName];
    
    if(!sourceSubViewView || !targetSubViewView)
        return nil;
    
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    context.name = viewName;
    context.visibility = CKViewTransitionContextVisibilityAlways;
    context.snapshot = [CKViewTransitionContext snapshotView:targetSubViewView withHierarchy:NO context:context];
    context.snapshot.name = viewName;
    
    UICollectionViewLayoutAttributes* cellStartAttributes = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    cellStartAttributes.alpha = 1;
    
    [self adjustAttributes:cellStartAttributes forSubView:sourceSubViewView inView:sourceView];
    context.startAttributes = cellStartAttributes;
    
    UICollectionViewLayoutAttributes* cellEndAttributes = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    cellEndAttributes.alpha = 1;
    
    [self adjustAttributes:cellEndAttributes forSubView:targetSubViewView inView:targetView];
    context.endAttributes = cellEndAttributes;
    
    context.viewsToHideDuringTransition = @[sourceView,targetView];
    
    return context;
}

+ (CKViewTransitionContext*)contextForSubviewViewNamed:(NSString*)viewName
                                                  view:(UIView*)view{
    
    UIView* sourceView  = [view viewWithName:viewName];
    
    if(!sourceView)
        return nil;
    
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    context.name = viewName;
    context.visibility = CKViewTransitionContextVisibilityAlways;
    context.snapshot = [CKViewTransitionContext snapshotView:sourceView withHierarchy:NO context:context];
    context.snapshot.name = viewName;
    
    
    UICollectionViewLayoutAttributes* cellStartAttributes = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    cellStartAttributes.alpha = 1;
    
    [self adjustAttributes:cellStartAttributes forSubView:sourceView inView:view];
    context.startAttributes = cellStartAttributes;
    
    UICollectionViewLayoutAttributes* cellEndAttributes = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    cellEndAttributes.alpha = 1;
    
    [self adjustAttributes:cellEndAttributes forSubView:sourceView inView:view];
    context.endAttributes = cellEndAttributes;
    
    context.viewsToHideDuringTransition = @[sourceView];
    
    return context;
}


+ (NSArray*)indexPathForView:(UIView*)view inView:(UIView*)parentView{
    NSMutableArray* indexes = [NSMutableArray array];
    
    UIView* superview = [view superview];
    UIView* currentView = view;
    while(superview){
        NSInteger index = [superview.subviews indexOfObjectIdenticalTo:currentView];
        [indexes insertObject:@(index) atIndex:0];
        
        if(superview == parentView)
            return indexes;
        
        currentView = superview;
        superview = currentView.superview;
    }
    
    return indexes;
}

+ (NSComparisonResult)compareIndexes:(NSArray*)indexes1 toIndexes:(NSArray*)indexes2{
    for(NSInteger i=0;i < MIN(indexes1.count,indexes2.count); ++i){
        NSInteger i1 = [[indexes1 objectAtIndex:i]integerValue];
        NSInteger i2 = [[indexes2 objectAtIndex:i]integerValue];
        
        if(i1 < i2)
            return NSOrderedAscending;
        
        if(i1 > i2)
            return NSOrderedDescending;
        
    }
    return [@(indexes1.count) compare:@(indexes2.count)];
}

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView
                                       targetView:(UIView*)targetView
                            ignoringViewWithNames:(NSArray*)ignoringViewWithNames{
    
    NSMutableArray* contexts = [NSMutableArray array];
    
    [sourceView layoutIfNeeded];
    [targetView layoutIfNeeded];
    
    NSArray* sourceSubviews = [[sourceView allSubviewsRecursive:YES]valueForKey:@"name"];
    NSArray* targetSubViews = targetView ? [[targetView allSubviewsRecursive:YES]valueForKey:@"name"] : sourceSubviews;
    
    NSMutableIndexSet* common = nil;
    NSMutableIndexSet* removed = nil;
    NSMutableIndexSet* added = nil;
    
    if(sourceSubviews == targetSubViews){
        common = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sourceSubviews.count)];
    }else{
        [sourceSubviews compareToArray:targetSubViews commonIndexSet:&common addedIndexSet:&added removedIndexSet:&removed identicalTo:NO];
        
        if(removed){
            NSArray* removedNames = [sourceSubviews objectsAtIndexes:removed];
            for(NSString* name in removedNames){
                if([name isKindOfClass:[NSNull class]] || [ignoringViewWithNames containsObject:name])
                    continue;
                
                CKViewTransitionContext* context = [CKViewTransitionContext contextForSubviewViewNamed:name
                                                                                                  view:sourceView];
                context.startAttributes.alpha = 1;
                context.endAttributes.alpha = 0;
                
                if(context){
                    [contexts addObject:context];
                }
            }
        }
        
        if(added){
            NSArray* addedNames = [targetSubViews objectsAtIndexes:added];
            for(NSString* name in addedNames){
                if([name isKindOfClass:[NSNull class]] || [ignoringViewWithNames containsObject:name])
                    continue;
                
                CKViewTransitionContext* context = [CKViewTransitionContext contextForSubviewViewNamed:name
                                                                                                  view:targetView];
                if(context){
                    context.startAttributes.alpha = 0;
                    context.endAttributes.alpha = 1;
                    
                    [contexts addObject:context];
                }
            }
        }
    }
    
    if(common){
        NSArray* commonNames = [sourceSubviews objectsAtIndexes:common];
        for(NSString* name in commonNames){
            if([name isKindOfClass:[NSNull class]] || [ignoringViewWithNames containsObject:name])
                continue;
            
            if([name isEqualToString:@"TokenHeaderBackgroundView"]){
                int i =3;
            }
            CKViewTransitionContext* context = [CKViewTransitionContext contextForSubviewViewNamed:name
                                                                                        sourceView:sourceView
                                                                                        targetView:targetView ? targetView : sourceView];
            if(context){
                [contexts addObject:context];
            }
        }
    }
    
    
    NSArray* sorted = [contexts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSArray*(^indexesForObject)(id object) = ^(id object){
            UIView* parent = targetView;
            UIView* view = [targetView viewWithName:[object name]];
            if(!view){
                parent = sourceView;
                view = [sourceView viewWithName:[object name]];
            }
            return [self indexPathForView:view inView:parent];
        };
        
        NSArray* indexes1 = indexesForObject(obj1);
        NSArray* indexes2 = indexesForObject(obj2);
        
        NSComparisonResult result = [self compareIndexes:indexes1 toIndexes:indexes2];
        return result;
    }];
    
    return sorted;
}


+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView {
    return [self contextsForSubviewsViewWithSourceView:sourceView targetView:nil ignoringViewWithNames:nil];
}

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView
                                       targetView:(UIView*)targetView{
    return [self contextsForSubviewsViewWithSourceView:sourceView targetView:targetView ignoringViewWithNames:nil];
}

+ (NSArray*)contextsForSubviewsViewWithSourceView:(UIView*)sourceView
                            ignoringViewWithNames:(NSArray*)viewNames{
    return [self contextsForSubviewsViewWithSourceView:sourceView targetView:nil ignoringViewWithNames:viewNames];
}


+ (CKViewTransitionContext*)contextForView:(UIView*)view
                         transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    return [self contextForView:view animation:CKViewTransitionContextAnimationNone transitionContext:transitionContext];
}

+ (CKViewTransitionContext*)contextForView:(UIView*)view
                                 animation:(CKViewTransitionContextAnimation)animation
                         transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    CKViewTransitionContext* context = [[[CKViewTransitionContext alloc]init]autorelease];
    context.visibility = CKViewTransitionContextVisibilityAlways;
    context.snapshot = [CKViewTransitionContext snapshotView:view withHierarchy:NO context:context];
    
    UICollectionViewLayoutAttributes* startAttributes = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    startAttributes.frame =  [view.superview convertRect:view.frame toView:[transitionContext containerView]];
    startAttributes.alpha = 1;

    context.startAttributes = startAttributes;
    
    UICollectionViewLayoutAttributes* endAttributes =  [CKViewTransitionContext attributesFromAttributes:startAttributes animation:animation transitionContext:transitionContext];
    context.endAttributes = endAttributes;
    
    return context;

}

@end
