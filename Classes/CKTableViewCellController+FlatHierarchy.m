//
//  CKTableViewCellController+FlatHierarchy.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-12.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+FlatHierarchy.h"

static char CKTableViewCellControllerOriginalViewKey;
static char CKTableViewCellControllerImageViewsKey;
static char CKTableViewCellControllerWantsFlatHierarchyKey;

const NSUInteger CKTableViewCellControllerFlatImageViewTag = 168;

@interface CKTableViewCellController (FlatHierarchyPrivate)

@property (nonatomic, retain) UIView *oldView;
@property (nonatomic, retain) NSMutableArray *imageViews;

@end

@implementation CKTableViewCellController (FlatHierarchy)

- (NSMutableArray *)imageViews {
    NSMutableArray *array = objc_getAssociatedObject(self, &CKTableViewCellControllerImageViewsKey);
    
    if (array == nil) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, &CKTableViewCellControllerImageViewsKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return array;
}

- (void)setImageViews:(NSMutableArray *)imageViews {
    objc_setAssociatedObject(self, &CKTableViewCellControllerImageViewsKey, imageViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.tableViewCell.superview != nil) {
            UIView * oldView = self.oldView;
            if (oldView == nil) {
                oldView = [[[UIView alloc] initWithFrame:self.tableViewCell.contentView.frame] autorelease];
                self.oldView = oldView;
                
                for (UIView * subview in self.tableViewCell.contentView.subviews) {
                    if ([subview isKindOfClass:[UIImageView class]]) {
                        [self.imageViews addObject:subview];
                        [subview removeFromSuperview];
                    }
                    else if (![subview isKindOfClass:[UIActivityIndicatorView class]])
                        [oldView addSubview:subview];
                }
            }
            
            [self setHighlighted:highlighted inView:self.oldView];
            [self setHighlighted:highlighted inView:self.tableViewCell.backgroundView];
            
            UIGraphicsBeginImageContextWithOptions(self.tableViewCell.backgroundView.bounds.size,
                                                   self.tableViewCell.backgroundView.isOpaque, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (highlighted)
                [self.tableViewCell.selectedBackgroundView.layer renderInContext:context];
            else
                [self.tableViewCell.backgroundView.layer renderInContext:context];
            
            [oldView.layer renderInContext:context];
            
            for (UIImageView *imageView in self.imageViews) {
                [imageView.image drawAtPoint:imageView.frame.origin];
            }
            
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
    });
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
    for (UIView * subview in self.imageViews) {
        [self.tableViewCell.contentView addSubview:subview];
    }
    
    self.imageViews = nil;
    self.oldView = nil;
}

@end
