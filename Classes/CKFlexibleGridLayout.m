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

@synthesize inset, layoutView;
@synthesize gridSize, minMarginSize;

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
    
    NSAssert(aGridSize.height != 0 && aGridSize.width != 0, @"0-size grid not supported");
    
    return gridLayout;
}

#pragma mark - Layout

- (void)layout {
    CGFloat width = self.layoutView.bounds.size.width - (self.inset.left + self.inset.right);
    CGFloat height = self.layoutView.bounds.size.height - (self.inset.top + self.inset.bottom);
    NSUInteger subviewCount = self.layoutView.subviews.count;
    
    //TODO allow frame changes
    //TODO take into account grid constraints in gridSize
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
            UIView *view = [self.layoutView.subviews objectAtIndex:viewIndex];
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
        CGFloat marginSize = (width - contentWidth - (numberOfViews - 1) * self.minMarginSize) / (numberOfViews + 1);
        currentWidth = self.inset.left + marginSize;
        for (NSUInteger index = initialViewIndex; index < viewIndex ; index ++) {
            UIView *view = [self.layoutView.subviews objectAtIndex:index];
            view.center = CGPointMake(currentWidth + view.frame.size.width / 2,  currentHeight + bestHeight / 2);
            
            currentWidth += view.frame.size.width + marginSize + self.minMarginSize;
        }
        
        rows ++;
        currentHeight += bestHeight + self.minMarginSize;
    }
    
    for (NSUInteger index = viewIndex; index < self.layoutView.subviews.count ; index ++) {
        UIView *viewToHide = [self.layoutView.subviews objectAtIndex:index];
        viewToHide.hidden = YES;
    }
}

@end
