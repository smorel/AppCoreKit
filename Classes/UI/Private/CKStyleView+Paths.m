//
//  CKStyleView+Paths.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView+Paths.h"

@implementation CKStyleView (Paths)

+ (CGMutablePathRef)generateTopEmbossPathWithBorderLocation:(CKStyleViewBorderLocation)borderLocation
                                                borderWidth:(CGFloat)borderWidth
                                                borderColor:(UIColor*)borderColor
                                          separatorLocation:(CKStyleViewSeparatorLocation)separatorLocation
                                             separatorWidth:(CGFloat)separatorWidth
                                             separatorColor:(UIColor*)separatorColor
                                                 cornerType:(CKStyleViewCornerType)cornerType
                                          roundedCornerSize:(CGFloat)roundedCornerSize
                                                       rect:(CGRect)rect{
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    UIRectCorner roundedCorners = UIRectCornerAllCorners;
    switch (cornerType) {
        case CKStyleViewCornerTypeTop:
            roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
            break;
        case CKStyleViewCornerTypeBottom:
            roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
            break;
        case CKStyleViewCornerTypeNone:
            roundedCorners = 0;
            break;
        default:
            break;
    }
    
    CGFloat offset = 0;
    
    if (borderLocation & CKStyleViewBorderLocationTop && borderColor && (borderColor != [UIColor clearColor])) {
        offset = borderWidth;
    }
    if (separatorLocation & CKStyleViewSeparatorLocationTop && separatorColor && (separatorColor != [UIColor clearColor])) {
        offset = MAX(offset,separatorWidth);
    }
    
    offset /= 2;
    
    CGFloat x = rect.origin.x +  offset;
    CGFloat y = rect.origin.y + (2 * offset) ;
    CGFloat width = rect.size.width - (2 * (offset));
    CGFloat radius = roundedCornerSize + (0 * offset)/* - offset + 3*/;
    
    
    CGPoint startLinePoint = CGPointMake(x, y + ((roundedCorners & UIRectCornerTopLeft) ? radius : 0));
    CGPoint endLinePoint = CGPointMake((roundedCorners & UIRectCornerTopRight) ? (x + width - radius) : x + width, y);
    
    CGPathMoveToPoint (path, nil, startLinePoint.x,startLinePoint.y );
    if(roundedCorners & UIRectCornerTopLeft){
        CGPathAddArc(path, nil,x + radius,y + radius,radius, M_PI,  3 * (M_PI / 2.0),NO);
    }
    CGPathAddLineToPoint (path, nil, endLinePoint.x,endLinePoint.y );
    if(roundedCorners & UIRectCornerTopRight){
        CGPathAddArc(path, nil,endLinePoint.x,endLinePoint.y + radius,radius, 3 * (M_PI / 2.0), 0,NO);
    }
    
    return path;
}

+ (CGMutablePathRef)generateBottomEmbossPathWithBorderLocation:(CKStyleViewBorderLocation)borderLocation
                                                   borderWidth:(CGFloat)borderWidth
                                                   borderColor:(UIColor*)borderColor
                                             separatorLocation:(CKStyleViewSeparatorLocation)separatorLocation
                                                separatorWidth:(CGFloat)separatorWidth
                                                separatorColor:(UIColor*)separatorColor
                                                    cornerType:(CKStyleViewCornerType)cornerType
                                             roundedCornerSize:(CGFloat)roundedCornerSize
                                                          rect:(CGRect)rect{
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    UIRectCorner roundedCorners = UIRectCornerAllCorners;
    switch (cornerType) {
        case CKStyleViewCornerTypeTop:
            roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
            break;
        case CKStyleViewCornerTypeBottom:
            roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
            break;
        case CKStyleViewCornerTypeNone:
            roundedCorners = 0;
            break;
        default:
            break;
    }
    
    CGFloat offset = 0;
    
    if (borderLocation & CKStyleViewBorderLocationBottom && borderColor&& (borderColor != [UIColor clearColor])) {
        offset = borderWidth;
    }
    if (separatorLocation & CKStyleViewSeparatorLocationBottom && separatorColor && (separatorColor != [UIColor clearColor])) {
        offset = MAX(offset,separatorWidth);
    }
    
    offset /= 2;
    
    CGFloat x = rect.origin.x +  offset;
    CGFloat y = rect.origin.y + rect.size.height - (2 * offset);
    CGFloat width = rect.size.width - (2 * (offset));
    CGFloat radius = roundedCornerSize + (0 * offset) /* - offset + 3*/;
    
    
    CGPoint startLinePoint = CGPointMake(x, ((roundedCorners & UIRectCornerBottomLeft) ? y - radius : y));
    CGPoint endLinePoint = CGPointMake((roundedCorners & UIRectCornerBottomRight) ? (x + width - radius) : x + width, y);
    
    CGPathMoveToPoint (path, nil, startLinePoint.x,startLinePoint.y );
    if(roundedCorners & UIRectCornerBottomLeft){
        CGPathAddArc(path, nil,startLinePoint.x + radius,startLinePoint.y,radius, -M_PI,  M_PI / 2,YES);
    }
    CGPathAddLineToPoint (path, nil, endLinePoint.x,endLinePoint.y );
    if(roundedCorners & UIRectCornerBottomRight){
        CGPathAddArc(path, nil,endLinePoint.x,endLinePoint.y - radius,radius, M_PI / 2.0, 0,YES);
    }
    
    return path;
}

#pragma mark - Border Path

+ (CGMutablePathRef)generateBorderPathWithBorderLocation:(CKStyleViewBorderLocation)borderLocation
                                             borderWidth:(CGFloat)borderWidth
                                              cornerType:(CKStyleViewCornerType)cornerType
                                       roundedCornerSize:(CGFloat)roundedCornerSize
                                                    rect:(CGRect)rect{
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    UIRectCorner roundedCorners = UIRectCornerAllCorners;
    switch (cornerType) {
        case CKStyleViewCornerTypeTop:
            roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
            break;
        case CKStyleViewCornerTypeBottom:
            roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
            break;
        case CKStyleViewCornerTypeNone:
            roundedCorners = 0;
            break;
        default:
            break;
    }
    
    CGFloat halfBorder = (borderWidth / 2.0);
    
    CGFloat x = rect.origin.x + halfBorder;
    CGFloat y = rect.origin.y + halfBorder;
    
    CGFloat width = rect.size.width - (2*halfBorder);
    CGFloat height = rect.size.height - (2*halfBorder);
    
    if(!(borderLocation & CKStyleViewBorderLocationTop)){
        y -= halfBorder;
        height += halfBorder;
    }
    
    if(!(borderLocation & CKStyleViewBorderLocationBottom)){
        height += halfBorder;
    }
    
    if(!(borderLocation & CKStyleViewBorderLocationLeft)){
        x -= halfBorder;
        width += halfBorder;
    }
    
    if(!(borderLocation & CKStyleViewBorderLocationRight)){
        width += halfBorder;
    }
    
    CGFloat radius = (roundedCorners != 0 && roundedCornerSize > 0) ? (roundedCornerSize - halfBorder) : 0;
    
    BOOL shouldMove = YES;
    if(borderLocation & CKStyleViewBorderLocationLeft){
        //draw arc from bottom to left or move to bottom left
        if((roundedCorners & UIRectCornerBottomLeft) && (borderLocation & CKStyleViewBorderLocationBottom)){
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x + radius, y + height);
                shouldMove = NO;
            }
            CGPathAddArc(path, nil,x + radius,y + height-radius,radius, M_PI / 2,  M_PI ,NO);
        }
        else{
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x, (roundedCorners & UIRectCornerBottomLeft) ? (y + height - radius) : (y + height));
                shouldMove = NO;
            }
        }
        
        //draw left line
        CGPathAddLineToPoint (path, nil, x, (roundedCorners & UIRectCornerTopLeft) ? y + radius : y);
        
        //draw arc from left to top
        if((roundedCorners & UIRectCornerTopLeft) && (borderLocation & CKStyleViewBorderLocationTop)){
            CGPathAddArc(path, nil,x + radius,y + radius,radius, M_PI,  3 * (M_PI / 2.0),NO);
            //CGPathAddArcToPoint (path, nil, 0, 0, radius, 0, radius);
        }
    }
    
    //draw top
    if(borderLocation & CKStyleViewBorderLocationTop){
        if(shouldMove){
            CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerTopLeft) ? x + radius : x, y);
            shouldMove = NO;
        }
        
        CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerTopRight) ? (x + width - radius) : (x + width), y);
        
        if(!(borderLocation & CKStyleViewBorderLocationRight) && (roundedCorners & UIRectCornerTopRight)){
            CGPathAddArc(path, nil,x + width - radius,y + radius,radius, 3 * (M_PI / 2.0),0  ,NO);
            shouldMove = YES;
        }
    } else shouldMove = YES;
    
    //draw right
    if(borderLocation & CKStyleViewBorderLocationRight){
        //draw arc from top to right or move to top right
        if((roundedCorners & UIRectCornerTopRight) && (borderLocation & CKStyleViewBorderLocationTop)){
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x + width - radius, y);
                shouldMove = NO;
            }
            CGPathAddArc(path, nil,x + width- radius,y + radius,radius, 3 * (M_PI / 2.0),0  ,NO);
            //CGPathAddArcToPoint (path, nil, width, 0, width, radius, radius);
        }
        else{
            if(shouldMove){
                CGPathMoveToPoint (path, nil, x + width, (roundedCorners & UIRectCornerTopRight) ? y + radius : y);
                shouldMove = NO;
            }
        }
        
        //draw right line
        CGPathAddLineToPoint (path, nil, x + width, (roundedCorners & UIRectCornerBottomRight) ? (y + height - radius) : (y + height));
        
        //draw arc from right to bottom
        if((roundedCorners & UIRectCornerBottomRight) && (borderLocation & CKStyleViewBorderLocationBottom)){
            CGPathAddArc(path, nil,x + width - radius,y + height - radius,radius, 0,  M_PI / 2.0,NO);
            //CGPathAddArcToPoint (path, nil, width, height, width - radius, height, radius);
        }
    } else shouldMove = YES;
    
    //draw bottom
    if(borderLocation & CKStyleViewBorderLocationBottom){
        if(shouldMove){
            CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerBottomRight) ? (x + width - radius) : x + width, y + height);
            shouldMove = NO;
        }
        CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerBottomLeft) ? x + radius : x, y + height);
    }
    
    return path;
}


@end
