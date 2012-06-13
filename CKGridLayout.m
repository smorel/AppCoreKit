//
//  CKGridLayout.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKGridLayout.h"

@implementation CKGridLayout

@synthesize inset, layoutContainer;
@synthesize gridSize, minMarginSize;
@synthesize preferedSize, maximumSize, minimumSize;

+ (CKGridLayout *)horizontalGridLayout {
    return [self gridLayoutWithGridSize:CGSizeMake(CGFLOAT_MAX, 1)];
}

+ (CKGridLayout *)verticalGridLayout {
    return [self gridLayoutWithGridSize:CGSizeMake(1, CGFLOAT_MAX)];
}

+ (CKGridLayout *)gridLayoutWithGridSize:(CGSize)aGridSize {
    CKGridLayout *gridLayout = [[[self alloc] init] autorelease];
    gridLayout.gridSize = aGridSize;
    
    NSAssert(aGridSize.height != 0 && aGridSize.width != 0, @"0-size grid not supported");
    
    return gridLayout;
}

#pragma mark - Layout

- (void)layout {
    CGFloat x = self.inset.left;
    CGFloat y = self.inset.top;
    CGFloat width = (self.layoutContainer.bounds.size.width - (self.inset.left + self.inset.right) - (self.gridSize.width - 1) * self.minMarginSize) / self.gridSize.width;
    CGFloat height = (self.layoutContainer.bounds.size.height - (self.inset.top + self.inset.bottom) - (self.gridSize.height - 1) * self.minMarginSize) / self.gridSize.height;
    
    NSUInteger i, j;
    for (i = 0,  j = 1; i < self.layoutContainer.subviews.count; i += 1, j += 1) {
        UIView *aView = [self.layoutContainer.subviews objectAtIndex:i];
        aView.center = CGPointMake(x + width / 2, y + height / 2);
        
        if (j >= self.gridSize.width) {
            y += height + self.minMarginSize;
            x = self.inset.left;
            j = 0;
        }
        else
            x += width + self.minMarginSize;
    }
    
    for (NSUInteger index = (self.gridSize.width * self.gridSize.height); index < self.layoutContainer.subviews.count ; index ++) {
        UIView *viewToHide = [self.layoutContainer.subviews objectAtIndex:index];
        viewToHide.hidden = YES;
    }
}

@end
