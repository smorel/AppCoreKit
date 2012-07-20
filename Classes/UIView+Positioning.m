//
//  UIView+Positioning.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "UIView+Positioning.h"


@implementation UIView (CKPositioning)
@dynamic x,y,width,height;

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x{
    CGRect theFrame = self.frame;
    theFrame.origin.x = x;
    self.frame = theFrame;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y{
    CGRect theFrame = self.frame;
    theFrame.origin.y = y;
    self.frame = theFrame;
}

- (CGFloat)width{
    return self.bounds.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect theFrame = self.frame;
    theFrame.size.width = width;
    self.frame = theFrame;
}

- (CGFloat)height{
    return self.bounds.size.height;
}

- (void)setHeight:(CGFloat)height{
    CGRect theFrame = self.frame;
    theFrame.size.height = height;
    self.frame = theFrame;
}

@end
