//
//  CKTableViewCellController+FlatHierarchy.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-12.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+FlatHierarchy.h"

static char CKTableViewCellControllerOriginalViewKey;
static char CKTableViewCellControllerWantsFlatHierarchyKey;

const NSUInteger CKTableViewCellControllerFlatImageViewTag = 168;

@interface CKTableViewCellController (FlatHierarchyPrivate)

@property (nonatomic, retain) UIView *oldView;

@end

@implementation CKTableViewCellController (FlatHierarchy)

- (UIView *)oldView {
    return objc_getAssociatedObject(self, &CKTableViewCellControllerOriginalViewKey);
}

- (void)setOldView:(UIView *)oldView {
    objc_setAssociatedObject(self, &CKTableViewCellControllerOriginalViewKey
                             , oldView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

- (BOOL)wantFlatHierarchy {
    return [objc_getAssociatedObject(self, &CKTableViewCellControllerWantsFlatHierarchyKey) boolValue];
}

- (void)setWantFlatHierarchy:(BOOL)wantFlatHierarchy {
    objc_setAssociatedObject(self, &CKTableViewCellControllerWantsFlatHierarchyKey,
                             [NSNumber numberWithBool:wantFlatHierarchy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)flattenHierarchyHighlighted:(BOOL)highlighted {
    if (self.tableViewCell.superview != nil) {
        UIView * oldView = self.oldView;
        if (oldView == nil) {
            oldView = [[[UIView alloc] initWithFrame:self.tableViewCell.contentView.frame] autorelease];
            self.oldView = oldView;
            
            for (UIView * subview in self.tableViewCell.contentView.subviews) {
                if (![subview isKindOfClass:[UIActivityIndicatorView class]])
                    [oldView addSubview:subview];
            }
        }
        
        [self setHighlighted:highlighted inView:self.oldView];
        [self setHighlighted:highlighted inView:self.tableViewCell.backgroundView];
        [self setHighlighted:highlighted inView:self.tableViewCell.selectedBackgroundView];
        
        UIGraphicsBeginImageContextWithOptions(self.tableViewCell.backgroundView.bounds.size,
                                               self.tableViewCell.backgroundView.isOpaque, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (highlighted)
            [self.tableViewCell.selectedBackgroundView.layer renderInContext:context];
        else
            [self.tableViewCell.backgroundView.layer renderInContext:context];
        
        [oldView.layer renderInContext:context];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = (UIImageView*) [self.tableViewCell viewWithTag:CKTableViewCellControllerFlatImageViewTag];
        if (imageView == nil) {
            imageView = [[[UIImageView alloc] initWithFrame:self.tableViewCell.backgroundView.frame] autorelease];
            imageView.tag = CKTableViewCellControllerFlatImageViewTag;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.tableViewCell insertSubview:imageView belowSubview:self.tableViewCell.contentView];
        }
        
        imageView.image = image;
    }
}

- (void)setHighlighted:(BOOL)highlighted inView:(UIView*)view {
    if ([view respondsToSelector:@selector(setHighlighted:)])
        [(UIButton*)view setHighlighted:highlighted];
    
    if (highlighted && [view isKindOfClass:[UILabel class]])
        [view setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *subview in view.subviews)
        [self setHighlighted:highlighted inView:subview];
}

- (void)restoreViews {
    UIImageView *imageView = (UIImageView*) [self.tableViewCell viewWithTag:CKTableViewCellControllerFlatImageViewTag];
    [imageView removeFromSuperview];
    
    for (UIView * subview in self.oldView.subviews) {
        [self.tableViewCell.contentView addSubview:subview];
    }
    self.oldView = nil;
}

@end
