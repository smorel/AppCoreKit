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

@interface CKShadowView()
- (BOOL)shadowEnabled;
- (void)setShadowEnabled:(BOOL)enabled;
@end


@interface CKHighlightView()
- (BOOL)highlightEnabled;
- (void)setHighlightEnabled:(BOOL)enabled;
@end


@implementation UIView (Transition)

+ (CKShadowView*)cloneShadowViewDecorators:(CKShadowView*)other root:(UIView*)root{
    CKShadowView* shadowView = [[[CKShadowView alloc]init]autorelease];
    
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.corners = other.corners;
    shadowView.roundedCornerSize = other.roundedCornerSize;
    shadowView.borderLocation = other.borderLocation;
    shadowView.borderShadowColor = other.borderShadowColor;
    shadowView.borderShadowRadius = other.borderShadowRadius;
    shadowView.borderShadowOffset = other.borderShadowOffset;
    
    CGRect rect = [other.superview convertRect:other.frame toView:root];
    shadowView.frame = rect;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return shadowView;
}

+ (CKHighlightView*)cloneHighlightViewDecorators:(CKHighlightView*)other root:(UIView*)root{
    CKHighlightView* highlightView = [[[CKHighlightView alloc]init]autorelease];
    
    highlightView.backgroundColor = [UIColor clearColor];
    highlightView.corners = other.corners;
    highlightView.roundedCornerSize = other.roundedCornerSize;
    highlightView.highlightColor = other.highlightColor;
    highlightView.highlightEndColor = other.highlightEndColor;
    highlightView.highlightCenter = other.highlightCenter;
    highlightView.highlightRadius = other.highlightRadius;
    highlightView.highlightWidth = other.highlightWidth;
    
    CGRect rect = [other.superview convertRect:other.frame toView:root];
    highlightView.frame = rect;
    highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return highlightView;
}


- (UIImage*)snapshotWithoutSubviews{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    NSArray* viewsToInclude = [self viewsToIncludeInTransitionSnapshot];
    
    //- I don't like this cause it will invalidate layouts
    NSMutableArray* viewsToShow = [NSMutableArray array];
    NSMutableArray* styleViewToRestore = [NSMutableArray array];
    for(UIView* v in self.subviews){
        if(![viewsToInclude containsObject:v]){
            if(!v.hidden){
                [viewsToShow addObject:v];
                v.hidden = YES;
            }
        }
        
        if([v isKindOfClass:[CKShadowView class]]){
            [styleViewToRestore addObject:v];
            [(CKShadowView*)v setShadowEnabled:NO];
        }
        
        if([v isKindOfClass:[CKHighlightView class]]){
            [styleViewToRestore addObject:v];
            [(CKHighlightView*)v setHighlightEnabled:NO];
        }
    }
    
    [self.layer renderInContext:contextRef];
    
    
    for(UIView* v in styleViewToRestore){
        if([v isKindOfClass:[CKShadowView class]]){
            [(CKShadowView*)v setShadowEnabled:YES];
        }
        if([v isKindOfClass:[CKHighlightView class]]){
            [(CKHighlightView*)v setHighlightEnabled:YES];
        }
    }
    
    for(UIView* v in viewsToShow){
        v.hidden = NO;
    }
    
    //-
    
    /* This doesn't draw background properly
     UIView* firstSubView = self.subviews.count > 0 ? [self.subviews objectAtIndex:0] : nil;
     CKStyleView* styleView = ([firstSubView isKindOfClass:[CKStyleView class]]) ? (CKStyleView*)firstSubView : nil;
     
     [self.layer drawInContext:contextRef];
     
     if(styleView){
     [styleView.layer drawInContext:contextRef];
     }*/
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

- (NSArray*)viewsToIncludeInTransitionSnapshot{
    if(self.subviews.count <= 0)
        return nil;
    
    if([[self.subviews objectAtIndex:0]isKindOfClass:[CKStyleView class]])
        return @[[self.subviews objectAtIndex:0]];
    
    return nil;
}

+ (void)installShadowViewDecorators:(CKShadowView*)styleView fromView:(UIView*)root inView:(UIView*)view name:(NSString*)name{
    if(styleView && ([styleView shadowEnabled])){
        CKShadowView* transitionStyleView = [[self class] cloneShadowViewDecorators:styleView root:root];
        transitionStyleView.name = name;
        [view addSubview:transitionStyleView];
    }
}

+ (void)installHighlightViewDecorators:(CKHighlightView*)highlightView fromView:(UIView*)root inView:(UIView*)view name:(NSString*)name{
    if(highlightView && ( [highlightView highlightEnabled])){
        CKHighlightView* transitionHighlightView = [[self class] cloneHighlightViewDecorators:highlightView root:root];
        transitionHighlightView.name = name;
        [view addSubview:transitionHighlightView];
    }
}

- (UIView*)transitionSnapshot{
    [self layoutSubviews];
    
    [self setStyleViewsDecoratorsEnabled:NO];
    
    
    UIView* snapshot = [[[UIImageView alloc]initWithImage:[self snapshotWithoutSubviews]]autorelease];
    snapshot.frame = self.bounds;
    
    CKShadowView* styleView = [self shadowView];
    if(styleView){
        [[self class]installShadowViewDecorators:styleView fromView:self inView:snapshot name:self.name];
    }
    
    CKHighlightView* highlightView = [self highlightView];
    if(highlightView){
        [[self class]installHighlightViewDecorators:highlightView fromView:self inView:snapshot name:self.name];
    }
    
    return snapshot;
}

- (UIView*)transitionSnapshotAfterUpdate{
    [self layoutSubviews];
    
      [self setStyleViewsDecoratorsEnabled:NO];
    
    UIView* snapshot = [self snapshotViewAfterScreenUpdates:YES];
    snapshot.frame = self.bounds;
    
    //if there are styleviews with dynamic highlight or shadows embedded in the hierarchy, they are snapshot instead of cloned with live update !
    [self installStyleViewDecoratorsFromView:self inView:snapshot];
    
    
    return snapshot;
}

- (void)installStyleViewDecoratorsFromView:(UIView*)root inView:(UIView*)view{
    CKShadowView* styleView = [self shadowView];
    if(styleView){
        [[self class]installShadowViewDecorators:styleView fromView:root inView:view name:self.name];
    }
    
    CKHighlightView* highlightView = [self highlightView];
    if(highlightView){
        [[self class]installHighlightViewDecorators:highlightView fromView:root inView:view name:self.name];
    }
    
    for(UIView* subview in self.subviews){
        [subview installStyleViewDecoratorsFromView:root inView:view];
    }
}


- (void)setStyleViewsDecoratorsEnabled:(BOOL)enabled{
    CKShadowView* styleView = [self shadowView];
    if(styleView){
        if(enabled){
            [styleView updateEffect];
        }
        //[styleView setHighlightEnabled:enabled];
        [styleView setShadowEnabled:enabled];
    }
    
    CKHighlightView* highlightView = [self highlightView];
    if(highlightView){
        if(enabled){
            [highlightView updateEffect];
        }
        //[styleView setHighlightEnabled:enabled];
        [highlightView setHighlightEnabled:enabled];
    }
    
    for(UIView* subview in self.subviews){
        [subview setStyleViewsDecoratorsEnabled:enabled];
    }
}

@end
