//
//  CKFlexibleGridLayout.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKFlexibleGridLayout.h"
#import "CKLayoutView.h"
#import <CloudKit/UIView+LayoutHelper.h>

@implementation CKFlexibleGridLayout

@synthesize inset, layoutContainer;
@synthesize gridSize, minMarginSize;
@synthesize horizontalLayout;

+ (CKFlexibleGridLayout *)horizontalGridLayout {
    return [self gridLayoutWithGridSize:CGSizeMake(CGFLOAT_MAX, 1)];
}

+ (CKFlexibleGridLayout *)verticalGridLayout {
    return [self gridLayoutWithGridSize:CGSizeMake(1, CGFLOAT_MAX)];
}

+ (CKFlexibleGridLayout *)gridLayoutWithGridSize:(CGSize)aGridSize {
    CKFlexibleGridLayout *gridLayout = [[[self alloc] init] autorelease];
    gridLayout.gridSize = aGridSize;
    
    gridLayout.minMarginSize = 5;
    gridLayout.inset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    gridLayout.horizontalLayout = CKFlexibleGridQueueFromRightHorizontalLayout;
    
    NSAssert(aGridSize.height != 0 && aGridSize.width != 0, @"0-size grid not supported");
    
    return gridLayout;
}

#pragma mark - Layout

- (void)layout {
    CGFloat width = self.layoutContainer.bounds.size.width - (self.inset.left + self.inset.right);
    CGFloat height = self.layoutContainer.bounds.size.height - (self.inset.top + self.inset.bottom);
    NSUInteger subviewCount = self.layoutContainer.subviews.count;
    
    //TODO allow frame changes
    NSUInteger viewIndex = 0;
    CGFloat currentHeight = self.inset.top;
    NSUInteger rows = 0;
    while (currentHeight < height && subviewCount > viewIndex && rows < self.gridSize.height) {
        CGFloat currentWidth = 0;
        CGFloat contentWidth = 0;
        CGFloat bestHeight = 0;
        NSUInteger initialViewIndex = viewIndex;
        NSUInteger column = 0;
        while (currentWidth < width && subviewCount > viewIndex  && column < self.gridSize.width) {
            UIView *view = [self.layoutContainer.subviews objectAtIndex:viewIndex];
            if (currentWidth + view.preferedSize.width + self.minMarginSize < width) {
                currentWidth += view.preferedSize.width;
                currentWidth += self.minMarginSize;
                contentWidth += view.preferedSize.width;
                
                bestHeight = MAX(bestHeight, view.preferedSize.height);
                viewIndex ++;
                column ++;
            }
            else
                break;
        }
        
        NSUInteger numberOfViews = (viewIndex - initialViewIndex);
        CGFloat marginSize;
        if (self.horizontalLayout == CKFlexibleGridMiddleHorizontalLayout)
            marginSize = (width - contentWidth - (numberOfViews - 1) * self.minMarginSize) / (numberOfViews + 1);
        else if (self.horizontalLayout == CKFlexibleGridQueueFromLeftHorizontalLayout || self.horizontalLayout == CKFlexibleGridQueueFromRightHorizontalLayout)
            marginSize = self.minMarginSize;
        else
            marginSize = width / numberOfViews;
        
        if (self.horizontalLayout == CKFlexibleGridQueueFromRightHorizontalLayout)
            currentWidth = self.inset.left + (width - contentWidth - (numberOfViews - 1) * self.minMarginSize);
        else
            currentWidth = self.inset.left + (self.horizontalLayout == CKFlexibleGridMiddleHorizontalLayout) * marginSize;
        
        for (NSUInteger index = initialViewIndex; index < viewIndex ; index ++) {
            UIView *view = [self.layoutContainer.subviews objectAtIndex:index];
            
            switch (self.horizontalLayout) {
                case CKFlexibleGridLeftHorizontalLayout:
                    view.center = CGPointMake(currentWidth + view.frame.size.width / 2,  currentHeight + bestHeight / 2);
                    break;
                case CKFlexibleGridMiddleHorizontalLayout:
                    view.center = CGPointMake(currentWidth + view.frame.size.width / 2,  currentHeight + bestHeight / 2);
                    break;
                case CKFlexibleGridRightHorizontalLayout:
                    view.center = CGPointMake(currentWidth + marginSize - view.frame.size.width / 2,  currentHeight + bestHeight / 2);
                    break;
                case CKFlexibleGridQueueFromLeftHorizontalLayout:
                case CKFlexibleGridQueueFromRightHorizontalLayout:
                    view.center = CGPointMake(currentWidth + view.frame.size.width / 2, currentHeight + bestHeight / 2);
                    break;
            }
            
            if (self.horizontalLayout == CKFlexibleGridMiddleHorizontalLayout)
                currentWidth += view.frame.size.width + marginSize + self.minMarginSize;
            else if (self.horizontalLayout == CKFlexibleGridQueueFromLeftHorizontalLayout || self.horizontalLayout == CKFlexibleGridQueueFromRightHorizontalLayout)
                currentWidth += view.preferedSize.width + self.minMarginSize;
            else
                currentWidth += marginSize;
        }
        
        rows ++;
        currentHeight += bestHeight + self.minMarginSize;
    }
    
    for (NSUInteger index = viewIndex; index < self.layoutContainer.subviews.count ; index ++) {
        UIView *viewToHide = [self.layoutContainer.subviews objectAtIndex:index];
        viewToHide.hidden = YES;
    }
}

@end
