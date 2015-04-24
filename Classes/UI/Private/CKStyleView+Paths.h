//
//  CKStyleView+Paths.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"

@interface CKStyleView (Paths)


+ (CGMutablePathRef)generateTopEmbossPathWithBorderLocation:(CKStyleViewBorderLocation)borderLocation
                                                borderWidth:(CGFloat)borderWidth
                                                borderColor:(UIColor*)borderColor
                                          separatorLocation:(CKStyleViewSeparatorLocation)separatorLocation
                                             separatorWidth:(CGFloat)separatorWidth
                                             separatorColor:(UIColor*)separatorColor
                                                 cornerType:(CKStyleViewCornerType)cornerType
                                          roundedCornerSize:(CGFloat)roundedCornerSize
                                                       rect:(CGRect)rect;

+ (CGMutablePathRef)generateBottomEmbossPathWithBorderLocation:(CKStyleViewBorderLocation)borderLocation
                                                   borderWidth:(CGFloat)borderWidth
                                                   borderColor:(UIColor*)borderColor
                                             separatorLocation:(CKStyleViewSeparatorLocation)separatorLocation
                                                separatorWidth:(CGFloat)separatorWidth
                                                separatorColor:(UIColor*)separatorColor
                                                    cornerType:(CKStyleViewCornerType)cornerType
                                             roundedCornerSize:(CGFloat)roundedCornerSize
                                                          rect:(CGRect)rect;

+ (CGMutablePathRef)generateBorderPathWithBorderLocation:(CKStyleViewBorderLocation)borderLocation
                                             borderWidth:(CGFloat)borderWidth
                                              cornerType:(CKStyleViewCornerType)cornerType
                                       roundedCornerSize:(CGFloat)roundedCornerSize
                                                    rect:(CGRect)rect;

@end
