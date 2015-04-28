//
//  CKStyleView+Light.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView+Light.h"
#import "CKStyleView+Paths.h"
#import "CoreGraphics+Additions.h"
#import "UIColor+Additions.h"
#import "UIColor+Components.h"
#import "CKImageCache.h"

@interface CKStyleView()
@property(nonatomic,retain) NSMutableArray* observedViews;
@property(nonatomic,assign)CGRect lastShadowFrame;
@property(nonatomic,assign)CGRect lastHighlightFrame;
- (void)regenerateShadow;
- (void)regenerateHighlight;
@end

@implementation CKStyleView (Shadow)

- (BOOL)shadowEnabled{
    return self.borderShadowColor!= nil && self.borderShadowColor != [UIColor clearColor] && self.borderShadowRadius > 0;
}

- (CGRect)shadowImageViewFrame{
    if([self shadowEnabled]){
        //Shadow
        
        UIRectCorner roundedCorners = UIRectCornerAllCorners;
        switch (self.corners) {
            case CKStyleViewCornerTypeTop:
                roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
                break;
            case CKStyleViewCornerTypeBottom:
                roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
                break;
                
            default:
                break;
        }
        
        CGFloat multiplier = 1;
        CGRect shadowFrame = self.frame;
        CGPoint offset = CGPointMake(0,0);
        
        if(self.borderLocation & CKStyleViewBorderLocationLeft){
            offset.x += multiplier * self.borderShadowRadius;
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
            
        }
        if(self.borderLocation & CKStyleViewBorderLocationRight){
            shadowFrame.size.width += multiplier * self.borderShadowRadius;
        }
        if(self.borderLocation & CKStyleViewBorderLocationTop){
            offset.y += multiplier * self.borderShadowRadius;
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        if(self.borderLocation & CKStyleViewBorderLocationBottom){
            shadowFrame.size.height += multiplier * self.borderShadowRadius;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationBottom && self.borderShadowOffset.height > 0){
            shadowFrame.size.height += self.borderShadowOffset.height;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationTop && self.borderShadowOffset.height < 0){
            offset.y -= self.borderShadowOffset.height;
            shadowFrame.size.height += -self.borderShadowOffset.height;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationRight && self.borderShadowOffset.width > 0){
            shadowFrame.size.width += self.borderShadowOffset.width;
        }
        
        if(self.borderLocation & CKStyleViewBorderLocationLeft && self.borderShadowOffset.width < 0){
            offset.x -= self.borderShadowOffset.width;
            shadowFrame.size.width += -self.borderShadowOffset.width;
        }
        
        shadowFrame.origin.x -= offset.x;
        shadowFrame.origin.y -= offset.y;
        
        return CGRectIntegral(shadowFrame);
    }
    
    return self.frame;
}

- (UIImage*)generateShadowImage{
    UIImage* result = nil;
    @autoreleasepool {

        //TODO: compute the smallest resizable image taking care of shadow radius and roundedcornerswidth
        CGRect frame = self.frame;
        
        CGRect shadowFrame = [self shadowImageViewFrame];
        
        CGSize minimumDrawSize = CGSizeMake(( 2*(self.borderShadowRadius + self.roundedCornerSize)) + 1+ fabs(self.borderShadowOffset.width),
                                            (2* (self.borderShadowRadius + self.roundedCornerSize)) + 1 + fabs(self.borderShadowOffset.height));
        
        CGRect imageRect =  CGRectIntegral(CGRectMake(0,0,
                                      shadowFrame.size.width - (frame.size.width) + minimumDrawSize.width,
                                      shadowFrame.size.height - (frame.size.height) + minimumDrawSize.height));
        
        CGRect drawRect = CGRectMake(-shadowFrame.origin.x ,
                                     -shadowFrame.origin.y,
                                     minimumDrawSize.width,
                                     minimumDrawSize.height);
        
        UIEdgeInsets resizableInsets = UIEdgeInsetsMake(self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.height),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.width),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.height),
                                                        self.borderShadowRadius + self.roundedCornerSize + fabs(self.borderShadowOffset.width));
        
        CGSize size = imageRect.size;
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawShadowInRect:drawRect inContext:context];
        [self clearContentInRect:drawRect inContext:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
         result = [[image resizableImageWithCapInsets:resizableInsets resizingMode:UIImageResizingModeStretch]retain];
    }
    
    return [result autorelease];
}

- (void)clearContentInRect:(CGRect)rect inContext:(CGContextRef)gc{
    
    CGContextSaveGState(gc);
    
    CGMutablePathRef clippingPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll borderWidth:0 cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
    CGContextAddPath(gc, clippingPath);
    CGContextClip(gc);
    
    CGContextClearRect(gc, rect);
    
    CFRelease(clippingPath);
    
    CGContextRestoreGState(gc);
}

- (void)drawShadowInRect:(CGRect)rect inContext:(CGContextRef)gc{
    // Shadow
    if(self.borderLocation != CKStyleViewBorderLocationNone){
        CGContextSaveGState(gc);
        
        if(self.borderShadowColor!= nil && self.borderShadowColor != [UIColor clearColor] && self.borderShadowRadius > 0){
            CGContextSetShadowWithColor(gc, self.borderShadowOffset, self.borderShadowRadius, self.borderShadowColor.CGColor);
            
            CGRect shadowRect = rect;
            if(!(self.borderLocation & CKStyleViewBorderLocationTop)){
                shadowRect.origin.y -= self.borderShadowRadius;
                shadowRect.size.height += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom)){
                shadowRect.size.height += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft)){
                shadowRect.origin.x -= self.borderShadowRadius;
                shadowRect.size.width += self.borderShadowRadius;
            }
            if(!(self.borderLocation & CKStyleViewBorderLocationRight)){
                shadowRect.size.width += self.borderShadowRadius;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationBottom) && self.borderShadowOffset.height < 0){
                shadowRect.size.height -= self.borderShadowOffset.height;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationTop) && self.borderShadowOffset.height > 0){
                shadowRect.origin.y -= self.borderShadowOffset.height;
                shadowRect.size.height += self.borderShadowOffset.height;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationRight) && self.borderShadowOffset.width < 0){
                shadowRect.size.width -= self.borderShadowOffset.width;
            }
            
            if(!(self.borderLocation & CKStyleViewBorderLocationLeft) && self.borderShadowOffset.width > 0){
                shadowRect.origin.x -= self.borderShadowOffset.width;
                shadowRect.size.width += self.borderShadowOffset.width;
            }
            
            if (self.corners != CKStyleViewCornerTypeNone){
                CGMutablePathRef shadowPath = CGPathCreateMutable();
                if (self.corners != CKStyleViewCornerTypeNone) {
                    shadowPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll  borderWidth:0 cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:shadowRect];
                }
                
                [[UIColor blackColor] setFill];
                CGContextAddPath(gc, shadowPath);
                CGContextFillPath(gc);
                CFRelease(shadowPath);
            }else{
                [[UIColor blackColor] setFill];
                CGContextFillRect(gc, shadowRect);
            }
            
        }
        
        CGContextRestoreGState(gc);
    }
}

- (BOOL)highlightEnabled{
    return self.highlightColor!= nil && self.highlightColor != [UIColor clearColor] && self.highlightWidth > 0;
}


#define LIGTH_EXPERIMENT

#ifdef LIGTH_EXPERIMENT

- (void)willMoveToWindow:(UIWindow *)newWindow{
    
    if(newWindow == nil){
        [self unregisterSuperviewFrameObservers];
    }
}

- (void)didMoveToWindow{
    
    [self registerSuperviewFrameObservers];
}

- (void)unregisterSuperviewFrameObservers{
    for(UIView* view in self.observedViews){
        [view removeObserver:self forKeyPath:@"frame"];
        if([view isKindOfClass:[UIScrollView class]]){
            [view removeObserver:self forKeyPath:@"contentOffset"];
        }
    }
    self.observedViews = nil;
}


- (void)registerSuperviewFrameObservers{
    [self unregisterSuperviewFrameObservers];
    
    self.observedViews = [NSMutableArray array];

    UIView* view = [self superview];
    while(view){
        [self.observedViews addObject:view];
        [view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        if([view isKindOfClass:[UIScrollView class]]){
            [view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
        view = [view superview];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([object isKindOfClass:[UIView class]] && [keyPath isEqualToString:@"frame"]){
        [self updateShadowWithLight];
        [self updateHighlightWithLight];
    }else if([object isKindOfClass:[UIView class]] && [keyPath isEqualToString:@"contentOffset"]){
        [self updateShadowWithLight];
        [self updateHighlightWithLight];
    }
}

- (void)updateShadowWithLight{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),   ^ {
        if([self updateShadowOffsetWithLight]){
            [self regenerateShadow];
        }
    });
}

- (BOOL)updateShadowOffsetWithLight{
    if(![self shadowEnabled] || !self.window)
        return NO;
    
    CGPoint lightPosition = self.lightPosition;
    CGFloat lightIntensity = self.lightIntensity;
    CGPoint lightDirection = self.lightDirection;
    
    CGRect rect = [self.superview convertRect:self.frame toView:self.window];
    //if(CGRectEqualToRect(self.lastShadowFrame, rect))
    //     return NO;
    self.lastShadowFrame = rect;
    
    CGPoint diff = CGPointMake(rect.origin.x + rect.size.width - lightPosition.x,rect.origin.y + rect.size.height - lightPosition.y );
    
    CGPoint direction = CKCGPointNormalize( diff );
    
    CGSize offset = CGSizeMake((NSInteger)(direction.x * lightIntensity) , (NSInteger)(direction.y * lightIntensity) );
    [self setBorderShadowOffset:offset];
    
    return YES;
}


- (BOOL)updateHighlightOffsetWithLight{
    if(![self highlightEnabled] || !self.window)
        return NO;
    
    CGPoint lightPosition = self.lightPosition;
    CGFloat lightIntensity = self.lightIntensity;
    CGPoint lightDirection = self.lightDirection;
    
    CGRect rect = [self.superview convertRect:self.frame toView:self.window];
    // if(CGRectEqualToRect(self.lastHighlightFrame, rect))
    //    return NO;
    self.lastHighlightFrame = rect;
    
    CGPoint nonNormalizedLightDirection = CGPointMake(lightDirection.x * self.window.bounds.size.width * 2,lightDirection.y * self.window.bounds.size.height * 2);
    
    CGPoint intersection = CKCGRectIntersect(rect,lightPosition,nonNormalizedLightDirection);
    
    self.highlightCenter = intersection;
    return !CGPointEqualToPoint(intersection,CGPointZero);
}

- (void)updateHighlightWithLight{
    if([self updateHighlightOffsetWithLight]){
        [self regenerateHighlight];
    }
}

#else

- (void)updateShadowOffsetWithLight {}

- (BOOL)updateHighlightOffsetWithLight {}

#endif

@end
