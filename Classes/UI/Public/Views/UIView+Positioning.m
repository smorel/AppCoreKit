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

- (void)setFrame:(CGRect)frame animated:(BOOL)animated{
    if(!animated){
        [CATransaction begin];
        [CATransaction
         setValue: [NSNumber numberWithBool: YES]
         forKey: kCATransactionDisableActions];
        self.frame = frame;
        [CATransaction commit];
    }else{
        self.frame = frame;
    }
}

- (void)populateSubviews:(NSMutableArray*)subviews recursive:(BOOL)recursive{
    for(UIView* subview in self.subviews){
        [subviews addObject:subview];
        if(recursive){
            [subview populateSubviews:subviews recursive:recursive];
        }
    }
}

- (NSArray*)allSubviewsRecursive:(BOOL)recursive{
    NSMutableArray* array = [NSMutableArray array];
    [self populateSubviews:array recursive:recursive];
    return array;
}

@end




