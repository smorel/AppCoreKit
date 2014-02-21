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
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

@end



@implementation UIScrollView(Snaphot)

- (UIImage*)snapshot{
    UIScrollView *renderedView = (UIScrollView *)self;
    CGPoint offset = renderedView.contentOffset;
    
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    [[UIColor clearColor]setFill];
    CGContextFillRect(contextRef, CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height));
    
    CGContextSaveGState(contextRef);
    CGContextTranslateCTM(contextRef, -offset.x, -offset.y);
    
    [self.layer renderInContext:contextRef];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(contextRef);
    UIGraphicsEndImageContext();
    
    
    if(scale != 1){
        return [[[UIImage alloc]initWithCGImage:resultingImage.CGImage scale:scale orientation:resultingImage.imageOrientation]autorelease];
    }
    
    return resultingImage;
}

@end