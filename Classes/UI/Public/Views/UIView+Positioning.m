//
//  UIView+Positioning.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "UIView+Positioning.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIView (CKPositioning)
@dynamic x,y,width,height;

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x{
    CGRect theFrame = self.frame;
    if(theFrame.origin.x != x){
        [self willChangeValueForKey:@"frame"];
        theFrame.origin.x = x;
        self.frame = theFrame;
        [self didChangeValueForKey:@"frame"];
    }
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y{
    CGRect theFrame = self.frame;
    if(theFrame.origin.y != y){
        [self willChangeValueForKey:@"frame"];
        theFrame.origin.y = y;
        self.frame = theFrame;
        [self didChangeValueForKey:@"frame"];
    }
}

- (CGFloat)width{
    return self.bounds.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect theFrame = self.frame;
    if(theFrame.size.width != width){
        [self willChangeValueForKey:@"frame"];
        theFrame.size.width = width;
        self.frame = theFrame;
        [self didChangeValueForKey:@"frame"];
    }
}

- (CGFloat)height{
    return self.bounds.size.height;
}

- (void)setHeight:(CGFloat)height{
    CGRect theFrame = self.frame;
    if(theFrame.size.height != height){
        [self willChangeValueForKey:@"frame"];
        theFrame.size.height = height;
        self.frame = theFrame;
        [self didChangeValueForKey:@"frame"];
    }
}


- (BOOL)hasSuperviewWithClass:(Class)type{
    UIView* currentView = self;
    while(currentView){
        if([currentView isKindOfClass:type])
            return YES;
        currentView = [currentView superview];
    }
    return NO;
}

@end


@implementation UIView(Snaphot)

- (UIImage*)snapshot{
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end



@implementation UIScrollView(Snaphot)

- (UIImage*)snapshot{
    UIScrollView *renderedView = (UIScrollView *)self;
    CGPoint offset = renderedView.contentOffset;
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, -offset.x, -offset.y);
    [self.layer renderInContext:contextRef];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(contextRef);
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end