//
//  UIView+Transition.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIView+Transition.h"
#import "CKStyleView.h"
#import "CKStyleView+Light.h"
#import "UIView+Name.h"
#import "UIView+Snapshot.h"
#import "NSObject+Bindings.h"

@interface CKStyleView()
- (BOOL)shadowEnabled;
- (BOOL)highlightEnabled;
- (void)setShadowEnabled:(BOOL)enabled;
- (void)setHighlightEnabled:(BOOL)enabled;
@property(nonatomic,retain)UIImageView* shadowImageView;
@end


@implementation UIView (Transition)

+ (CKStyleView*)cloneStyleViewDecorators:(CKStyleView*)other root:(UIView*)root{
    CKStyleView* styleView = [[[CKStyleView alloc]init]autorelease];
    
    styleView.backgroundColor = [UIColor clearColor];
    styleView.corners = other.corners;
    styleView.roundedCornerSize = other.roundedCornerSize;
    styleView.borderLocation = other.borderLocation;
    styleView.borderShadowColor = other.borderShadowColor;
    styleView.borderShadowRadius = other.borderShadowRadius;
    styleView.borderShadowOffset = other.borderShadowOffset;
    /*styleView.highlightColor = other.highlightColor;
    styleView.highlightEndColor = other.highlightEndColor;
    styleView.highlightCenter = other.highlightCenter;
    styleView.highlightRadius = other.highlightRadius;
    styleView.highlightWidth = other.highlightWidth;
     */
    styleView.lightDirection = other.lightDirection;
    styleView.lightIntensity = other.lightIntensity;
    styleView.lightPosition = other.lightPosition;
    
    CGRect rect = [other.superview convertRect:other.frame toView:root];
    styleView.frame = rect;
    styleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return styleView;
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
        
        if([v isKindOfClass:[CKStyleView class]]){
            [styleViewToRestore addObject:v];
            [(CKStyleView*)v setShadowEnabled:NO];
            // [(CKStyleView*)v setHighlightEnabled:NO];
        }
    }
    
    [self.layer renderInContext:contextRef];
    
    
    for(CKStyleView* v in styleViewToRestore){
        [(CKStyleView*)v setShadowEnabled:YES];
        //[(CKStyleView*)v setHighlightEnabled:YES];
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

+ (void)installStyleViewDecorators:(CKStyleView*)styleView fromView:(UIView*)root inView:(UIView*)view name:(NSString*)name{
    if(styleView && ([styleView shadowEnabled] /*|| [styleView highlightEnabled]*/)){
        CKStyleView* transitionStyleView = [[self class] cloneStyleViewDecorators:styleView root:root];
        transitionStyleView.name = name;
        [view addSubview:transitionStyleView];
    }
}

- (UIView*)transitionSnapshot{
    [self layoutSubviews];
    
    //[self setStyleViewsDecoratorsEnabled:NO];
    
    CKStyleView* styleView = [self styleView];
    
    UIView* snapshot = [[[UIImageView alloc]initWithImage:[self snapshotWithoutSubviews]]autorelease];
    snapshot.frame = self.bounds;
    
    [[self class]installStyleViewDecorators:styleView fromView:self inView:snapshot name:self.name];
    
    return snapshot;
}

- (UIView*)transitionSnapshotAfterUpdate{
    [self layoutSubviews];
    
    //  [self setStyleViewsDecoratorsEnabled:NO];
    
    UIView* snapshot = [self snapshotViewAfterScreenUpdates:YES];
    snapshot.frame = self.bounds;
    
    //if there are styleviews with dynamic highlight or shadows embedded in the hierarchy, they are snapshot instead of cloned with live update !
    [self installStyleViewDecoratorsFromView:self inView:snapshot];
    
    
    return snapshot;
}

- (void)installStyleViewDecoratorsFromView:(UIView*)root inView:(UIView*)view{
    CKStyleView* styleView = [self styleView];
    if(styleView){
        [[self class]installStyleViewDecorators:styleView fromView:root inView:view name:self.name];
    }
    
    for(UIView* subview in self.subviews){
        [subview installStyleViewDecoratorsFromView:root inView:view];
    }
}


- (void)setStyleViewsDecoratorsEnabled:(BOOL)enabled{
    CKStyleView* styleView = [self styleView];
    if(styleView){
        if(enabled){
            [styleView updateLights];
        }
        //[styleView setHighlightEnabled:enabled];
        [styleView setShadowEnabled:enabled];
    }
    
    for(UIView* subview in self.subviews){
        [subview setStyleViewsDecoratorsEnabled:enabled];
    }
}

@end
