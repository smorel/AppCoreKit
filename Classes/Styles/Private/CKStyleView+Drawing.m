//
//  CKStyleView+Drawing.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView+Drawing.h"
#import "UIImage+Transformations.h"
#import "CKStyleView+Paths.h"
#import "UIColor+Additions.h"
#import "CKImageCache.h"

@interface CKStyleView ()
@property(nonatomic,retain)NSString* maskCacheIdentifier;
@property(nonatomic,retain)NSString* borderCacheIdentifier;
@property(nonatomic,retain)NSString* gradientCacheIdentifier;
@property(nonatomic,retain)NSString* separatorCacheIdentifier;
@property(nonatomic,retain)NSString* embossTopCacheIdentifier;
@property(nonatomic,retain)NSString* embossBottomCacheIdentifier;
@property(nonatomic,retain)UIColor* fillColor;
@property(nonatomic,assign)CGRect lastDrawBounds;
@end


@implementation CKStyleView (Drawing)

- (UIImage*)maskImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Mask_%lu_%f",
                                 (unsigned long)self.corners,self.roundedCornerSize];
    
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"maskCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGSize size = CGSizeMake(2*self.roundedCornerSize+1,2*self.roundedCornerSize+1);
        CGRect rect = CGRectMake(0,0,size.width,size.height);
        
        CGMutablePathRef highlightPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                               borderWidth:0
                                                                                cornerType:self.corners
                                                                         roundedCornerSize:self.roundedCornerSize
                                                                                      rect:rect];
        
        UIImage* maskImage = [UIImage maskImageWithPath:highlightPath size:size];
        maskImage = [maskImage resizableImageWithCapInsets:UIEdgeInsetsMake(self.roundedCornerSize, self.roundedCornerSize,self.roundedCornerSize,self.roundedCornerSize)
                                              resizingMode:UIImageResizingModeStretch];
        
        CGPathRelease(highlightPath);
        
        return maskImage;
    }];
}


- (UIImage*)borderImage{
    NSString* cacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Border_%lu_%f_%f_%lu_%@",
                                 (unsigned long)self.corners,self.roundedCornerSize,self.borderWidth,(unsigned long)self.borderLocation,self.borderColor];
    
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"borderCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGSize size = CGSizeMake(2*self.roundedCornerSize+1,2*self.roundedCornerSize+1);
        CGRect rect = CGRectMake(0,0,size.width,size.height);
        
        CGMutablePathRef path = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                      borderWidth:0
                                                                       cornerType:self.corners
                                                                roundedCornerSize:self.roundedCornerSize
                                                                             rect:rect];
        
        UIImage* image = [UIImage strokePathImageWithColor:self.borderColor path:path width:self.borderWidth size:size];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(self.roundedCornerSize, self.roundedCornerSize,self.roundedCornerSize,self.roundedCornerSize) resizingMode:UIImageResizingModeStretch];
        
        CGPathRelease(path);
        
        return image;
    }];
}

- (UIImage*)gradientImage{
    NSMutableString* cacheIdentifier = [NSMutableString stringWithFormat:@"CKStyleView_Border_%f_%f_%lu", self.bounds.size.width,self.bounds.size.height,(unsigned long)self.gradientStyle];
    for(UIColor* color in self.gradientColors){
        [cacheIdentifier appendString:[color description]];
    }
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"gradientCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGPoint startPoint;
        CGPoint endPoint;
        
        switch(self.gradientStyle){
            case CKStyleViewGradientStyleVertical:
                startPoint = CGPointMake(0,0);
                endPoint =  CGPointMake(0,self.bounds.size.height);
                break;
            case CKStyleViewGradientStyleHorizontal:
                startPoint = CGPointMake(0,0);
                endPoint =  CGPointMake(self.bounds.size.width,0);
                break;
        }
        
        return [UIImage linearGradientImageWithColors:self.gradientColors locations:self.gradientColorLocations startPoint:startPoint endPoint:endPoint size:self.bounds.size];
    }];
}


- (UIImage*)separatorImage{
    //To go fast, we regenerate full size images. We should draw resizable minimum size image here
    NSMutableString* cacheIdentifier = [NSMutableString stringWithFormat:@"CKStyleView_Separator_%f_%f_%@_%lu_%f_%lu_%lu_%@_%lu",
                                        self.bounds.size.width,self.bounds.size.height,
                                        self.separatorColor,(unsigned long)self.separatorWidth,self.separatorDashPhase,
                                        (unsigned long)self.separatorLineCap,(unsigned long)self.separatorLineJoin,
                                        NSStringFromUIEdgeInsets(self.separatorInsets),(unsigned long)self.separatorLocation];
    
    //separatorDashLengths

    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"separatorCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGRect rect = self.bounds;
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawSeparatorInRect:rect context:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }];
}

- (UIImage*)embossTopImage{
    //To go fast, we regenerate full size images. We should draw resizable minimum size image here
    NSMutableString* cacheIdentifier = [NSMutableString stringWithFormat:@"CKStyleView_EmbossTop_%f_%f_%@",
                                        self.bounds.size.width,self.bounds.size.height,
                                        self.embossTopColor];
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"embossTopCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGRect rect = self.bounds;
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawTopEmbossInRect:rect context:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }];
}

- (UIImage*)embossBottomImage{
    //To go fast, we regenerate full size images. We should draw resizable minimum size image here
    NSMutableString* cacheIdentifier = [NSMutableString stringWithFormat:@"CKStyleView_EmbossBottom_%f_%f_%@",
                                        self.bounds.size.width,self.bounds.size.height,
                                        self.embossBottomColor];
    
    return [[CKImageCache sharedInstance]findOrCreateImageWithHandler:self handlerCacheIdentifierProperty:@"embossBottomCacheIdentifier" cacheIdentifier:cacheIdentifier generateImageBlock:^UIImage *{
        CGRect rect = self.bounds;
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self drawBottomEmbossInRect:rect context:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }];
}


- (void)drawTopEmbossInRect:(CGRect)rect context:(CGContextRef)gc {
        CGContextSaveGState(gc);
        
        CGContextSetShadowWithColor(gc, CGSizeMake(0, 1), 0, self.embossTopColor.CGColor);
        
        CGMutablePathRef topEmbossPath = [CKStyleView generateTopEmbossPathWithBorderLocation:self.borderLocation borderWidth:self.borderWidth borderColor:self.borderColor separatorLocation:self.separatorLocation separatorWidth:self.separatorWidth separatorColor:self.separatorColor cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
        
        CGContextAddPath(gc, topEmbossPath);
        
        [[UIColor clearColor]setStroke];
        CGContextSetLineWidth(gc, 1);
        
        UIColor*thecolor = self.embossTopColor;
        [thecolor setStroke];
        
        CGContextStrokePath(gc);
        CFRelease(topEmbossPath);
        CGContextRestoreGState(gc);
}

- (void)drawBottomEmbossInRect:(CGRect)rect context:(CGContextRef)gc {
    
        CGContextSaveGState(gc);
        
        CGContextSetShadowWithColor(gc, CGSizeMake(0, -1), 0, self.embossBottomColor.CGColor);
        
        CGMutablePathRef bottomEmbossPath = [CKStyleView generateBottomEmbossPathWithBorderLocation:self.borderLocation borderWidth:self.borderWidth borderColor:self.borderColor separatorLocation:self.separatorLocation separatorWidth:self.separatorWidth separatorColor:self.separatorColor cornerType:self.corners roundedCornerSize:self.roundedCornerSize rect:rect];
        
        CGContextAddPath(gc, bottomEmbossPath);
        
        CGContextSetLineWidth(gc, 1);
        [[UIColor clearColor]setStroke];
        
        UIColor*thecolor = self.embossBottomColor;
        [thecolor setStroke];
        
        CGContextStrokePath(gc);
        CFRelease(bottomEmbossPath);
        CGContextRestoreGState(gc);
}

- (void)drawSeparatorInRect:(CGRect)rect context:(CGContextRef)gc {
    // Separator
        CGContextSaveGState(gc);
        [self.separatorColor setStroke];
        CGContextSetLineWidth(gc, self.separatorWidth);
        
        CGRect separatorRect = CGRectMake(rect.origin.x + self.separatorInsets.left,
                                          rect.origin.y + self.separatorInsets.top,
                                          rect.size.width - (self.separatorInsets.left + self.separatorInsets.right),
                                          rect.size.height - (self.separatorInsets.top + self.separatorInsets.bottom));
        
        CGMutablePathRef borderPath = [CKStyleView generateBorderPathWithBorderLocation:(CKStyleViewBorderLocation)self.separatorLocation borderWidth:self.separatorWidth cornerType:self.corners roundedCornerSize:self.roundedCornerSize  rect:separatorRect];
        
        CGContextAddPath(gc, borderPath);
        
        if(self.separatorDashLengths){
            CGFloat lengths[self.separatorDashLengths.count];
            int i =0;
            for(NSNumber* n in self.separatorDashLengths){
                lengths[i] = [[self.separatorDashLengths objectAtIndex:i]floatValue];
                ++i;
            }
            CGContextSetLineDash(gc, self.separatorDashPhase,lengths , [self.separatorDashLengths count]);
        }
        
        CGContextSetLineCap(gc,self.separatorLineCap);
        CGContextSetLineJoin(gc, self.separatorLineJoin);
        
        CFRelease(borderPath);
        CGContextStrokePath(gc);
        CGContextRestoreGState(gc);
}

@end
