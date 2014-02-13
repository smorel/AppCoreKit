//
//  UIScrollView+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/13/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "UIScrollView+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKRuntime.h"
#import <objc/runtime.h>
#import "CKStringHelper.h"

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;
- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index;
+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly;
+ (void)performLayoutWithFrame:(CGRect)theframe forBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)addLayoutBoxes:(NSArray*)boxes toBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)removeViewsFromBox:(NSObject<CKLayoutBoxProtocol>*)box recursively:(BOOL)recursively;
+ (void)removeLayoutBoxes:(NSArray*)boxes fromBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)initializeBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end


static char UIScrollViewFlexibleContentWidthKey;
static char UIScrollViewFlexibleContentHeightKey;
static char UIScrollViewManuallyManagesContentSizeKey;

@implementation UIScrollView (CKLayout)
@dynamic flexibleContentWidth, flexibleContentHeight, manuallyManagesContentSize;

- (void)setFlexibleContentWidth:(BOOL)enabled{
    objc_setAssociatedObject(self,
                             &UIScrollViewFlexibleContentWidthKey,
                             [NSNumber numberWithBool:enabled],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleContentWidth{
    id value = objc_getAssociatedObject(self, &UIScrollViewFlexibleContentWidthKey);
    return value ? [value boolValue] : YES;
}

- (void)setFlexibleContentHeight:(BOOL)enabled{
    objc_setAssociatedObject(self,
                             &UIScrollViewFlexibleContentHeightKey,
                             [NSNumber numberWithBool:enabled],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleContentHeight{
    id value = objc_getAssociatedObject(self, &UIScrollViewFlexibleContentHeightKey);
    return value ? [value boolValue] : YES;
}

- (void)setManuallyManagesContentSize:(BOOL)enabled{
    objc_setAssociatedObject(self,
                             &UIScrollViewManuallyManagesContentSizeKey,
                             [NSNumber numberWithBool:enabled],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)manuallyManagesContentSize{
    id value = objc_getAssociatedObject(self, &UIScrollViewManuallyManagesContentSizeKey);
    return value ? [value boolValue] : YES;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    CGSize subBoxesSize = CGSizeMake(self.flexibleContentWidth  ? MAXFLOAT : size.width,
                                     self.flexibleContentHeight ? MAXFLOAT : size.height);
    
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    if(self.layoutBoxes && [self.layoutBoxes count] > 0){
        CGFloat maxWidth = 0;
        CGFloat maxHeight = 0;
        
        subBoxesSize.width  -= self.padding.left + self.padding.right /*+ self.contentInset.left + self.contentInset.right*/;
        subBoxesSize.height -= self.padding.top + self.padding.bottom  /*+ self.contentInset.top + self.contentInset.bottom*/;
        
        for(NSObject<CKLayoutBoxProtocol>* box in self.layoutBoxes){
            CGSize constraint = subBoxesSize;
            
            CGSize s = [box preferredSizeConstraintToSize:constraint];
            
            if(s.width > maxWidth && s.width < MAXFLOAT)   maxWidth = s.width;
            if(s.height > maxHeight && s.height < MAXFLOAT) maxHeight = s.height;
        }
        
        subBoxesSize = CGSizeMake(maxWidth,maxHeight);
        
        subBoxesSize.width  += self.padding.left + self.padding.right /*+ self.contentInset.left + self.contentInset.right*/;
        subBoxesSize.height += self.padding.top + self.padding.bottom /*+ self.contentInset.top + self.contentInset.bottom*/;
    }else{
        if([self isKindOfClass:[UIControl class]]){
            subBoxesSize.width -= self.padding.left + self.padding.right /*+ self.contentInset.left + self.contentInset.right*/;
            subBoxesSize.height -= self.padding.top + self.padding.bottom;
            
            subBoxesSize = [self sizeThatFits:subBoxesSize];
            
            subBoxesSize.width += self.padding.left + self.padding.right /*+ self.contentInset.left + self.contentInset.right*/;
            subBoxesSize.height += self.padding.top + self.padding.bottom /*+ self.contentInset.top + self.contentInset.bottom*/;
        }
    }
    
    //Takes contentInset into account here !
    if(self.sizeToFitLayoutBoxes && self.layoutBoxes && [self.layoutBoxes count] > 0){
        size = [CKLayoutBox preferredSizeConstraintToSize:subBoxesSize forBox:self];
    }else if([self.containerLayoutBox isKindOfClass:[UIView class]]){
        size = [CKLayoutBox preferredSizeConstraintToSize: size forBox:self];
    }

    size = CGSizeMake(size.width - (self.padding.left + self.padding.right), size.height - (self.padding.top + self.padding.bottom));
    
    self.lastPreferedSize = CGSizeMake(size.width + self.padding.left + self.padding.right,size.height + self.padding.top + self.padding.bottom);
    return self.lastPreferedSize;
}


- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize constraint = theframe.size;
    if(self.sizeToFitLayoutBoxes && self.containerLayoutBox == nil && self.layoutBoxes && [self.layoutBoxes count] > 0){
        constraint.height = MAXFLOAT;
    }
    
    CGSize size = [self preferredSizeConstraintToSize:constraint];
    
    CGRect frame = CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height);
    
    CGRect subBoxesFrame = frame;
    
    
    //If the view has its own layout, the sub boxes are placed relative to it !
    if([self containerLayoutBox] == [self superview] || (self.layoutBoxes && [self.layoutBoxes count] > 0)){
        subBoxesFrame = CGRectMake(0,0,frame.size.width,frame.size.height);
    }
    
    
    //Apply padding
    subBoxesFrame = CGRectMake(subBoxesFrame.origin.x + self.padding.left,
                               subBoxesFrame.origin.y + self.padding.top,
                               subBoxesFrame.size.width  - (self.padding.left + self.padding.right) /*- (self.contentInset.left + self.contentInset.right)*/,
                               subBoxesFrame.size.height - (self.padding.top + self.padding.bottom) /*- (self.contentInset.top + self.contentInset.bottom)*/);
    
    CGSize adjustedSize = CGSizeMake(self.flexibleContentWidth    ? MAXFLOAT : subBoxesFrame.size.width,
                                     self.flexibleContentHeight   ? MAXFLOAT : subBoxesFrame.size.height);
    subBoxesFrame.size = adjustedSize;
    
    [CKLayoutBox performLayoutWithFrame:subBoxesFrame forBox:self];
    
    CGSize boundingBox = CGSizeMake(0, 0);
    for(NSObject<CKLayoutBoxProtocol>* subbox in self.layoutBoxes){
        if((subbox.frame.origin.x + subbox.frame.size.width) > boundingBox.width){
            boundingBox.width = subbox.frame.origin.x + subbox.frame.size.width;
        }
        if((subbox.frame.origin.y + subbox.frame.size.height) > boundingBox.height){
            boundingBox.height = subbox.frame.origin.y + subbox.frame.size.height;
        }
    }
    
    CGRect newFrame = CGRectMake(self.frame.origin.x,self.frame.origin.y,
                                 boundingBox.width  + (self.padding.left + self.padding.right),
                                 boundingBox.height + (self.padding.top + self.padding.bottom) );
    
    if(self.sizeToFitLayoutBoxes && self.layoutBoxes && [self.layoutBoxes count] > 0){
        CGRect frameWithInsets = CGRectMake(newFrame.origin.x, newFrame.origin.y,
                                            newFrame.size.width /*+ self.contentInset.left + self.contentInset.right*/,
                                            newFrame.size.height /*+self.contentInset.top +  self.contentInset.bottom*/);
        [self setBoxFrameTakingCareOfTransform:frameWithInsets];
    }else if([self.containerLayoutBox isKindOfClass:[UIView class]]){
        [self setBoxFrameTakingCareOfTransform:frame];
    }
    
    if(!self.manuallyManagesContentSize){
        self.contentSize = newFrame.size;
    }
}

/*- (void)UIScrollView_Layout_setContentInset:(UIEdgeInsets)insets{
    if(!UIEdgeInsetsEqualToEdgeInsets(insets, self.contentInset)){
        [self UIScrollView_Layout_setContentInset:insets];
        [self invalidateLayout];
    }
}

+ (void)load{
    CKSwizzleSelector([UIScrollView class], @selector(setContentInset:), @selector(UIScrollView_Layout_setContentInset:));
}*/

@end
