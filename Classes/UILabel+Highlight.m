//
//  UILabel+Highlight.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "UILabel+Highlight.h"
#import "CKRuntime.h"
#import "CKDebug.h"
#import <objc/runtime.h>

static char internalCopyOfShadowColorKey;
static char internalCopyOfBackgroundColorKey;
static char highlightedShadowColorKey;
static char highlightedBackgroundColorKey;
static char shadowColorAppliedKey;
static char backgroundColorAppliedKey;


@interface UILabel (CKHighlight_Private)
@property(nonatomic,retain) UIColor* internalCopyOfShadowColor;
@property(nonatomic,retain) UIColor* internalCopyOfBackgroundColor;
@property(nonatomic,assign) BOOL shadowColorApplied;
@property(nonatomic,assign) BOOL backgroundColorApplied;
@end

@implementation UILabel(CKHighlight_Private)
@dynamic internalCopyOfShadowColor,internalCopyOfBackgroundColor,shadowColorApplied,backgroundColorApplied;

- (void)setInternalCopyOfShadowColor:(UIColor *)internalCopyOfShadowColor{
    objc_setAssociatedObject(self, 
                             &internalCopyOfShadowColorKey,
                             internalCopyOfShadowColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor*)internalCopyOfShadowColor{
    return objc_getAssociatedObject(self, &internalCopyOfShadowColorKey);
}

- (void)setInternalCopyOfBackgroundColor:(UIColor *)internalCopyOfBackgroundColor{
    objc_setAssociatedObject(self, 
                             &internalCopyOfBackgroundColorKey,
                             internalCopyOfBackgroundColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (UIColor*)internalCopyOfBackgroundColor{
    return objc_getAssociatedObject(self, &internalCopyOfBackgroundColorKey);
}

- (void)setShadowColorApplied:(BOOL)shadowColorApplied{
    objc_setAssociatedObject(self, 
                             &shadowColorAppliedKey,
                             [NSNumber numberWithBool:shadowColorApplied],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shadowColorApplied{
    NSNumber* n = objc_getAssociatedObject(self, &shadowColorAppliedKey);
    return n? [n boolValue] : NO;
}

- (void)setBackgroundColorApplied:(BOOL)backgroundColorApplied{
    objc_setAssociatedObject(self, 
                             &backgroundColorAppliedKey,
                             [NSNumber numberWithBool:backgroundColorApplied],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)backgroundColorApplied{
    NSNumber* n = objc_getAssociatedObject(self, &backgroundColorAppliedKey);
    return n? [n boolValue] : NO;
}

@end

@implementation UILabel (CKHighlight)
@dynamic highlightedShadowColor,highlightedBackgroundColor;

- (void)setHighlightedShadowColor:(UIColor *)highlightedShadowColor{
    [self willChangeValueForKey:@"highlightedShadowColor"];
    objc_setAssociatedObject(self, 
                             &highlightedShadowColorKey,
                             highlightedShadowColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"highlightedShadowColor"];
}

- (UIColor*)highlightedShadowColor{
    return objc_getAssociatedObject(self, &highlightedShadowColorKey);
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor{
    [self willChangeValueForKey:@"highlightedBackgroundColor"];
    objc_setAssociatedObject(self, 
                             &highlightedBackgroundColorKey,
                             highlightedBackgroundColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"highlightedBackgroundColor"];
}

- (UIColor*)highlightedBackgroundColor{
    return objc_getAssociatedObject(self, &highlightedBackgroundColorKey);
}

- (void)ckSetHighlighted:(BOOL)highlighted{
    if(highlighted){
        if(self.highlightedShadowColor){
            if(!self.shadowColorApplied){
                self.internalCopyOfShadowColor = self.shadowColor;
                self.shadowColorApplied = YES;
            }
            self.shadowColor = self.highlightedShadowColor;
        }
        
        if(self.highlightedBackgroundColor){
            if(!self.backgroundColorApplied){
                self.internalCopyOfBackgroundColor = self.backgroundColor;
                self.backgroundColorApplied = YES;
            }
            self.backgroundColor = self.highlightedBackgroundColor;
        }
    }
    else{
        if(self.shadowColorApplied){
            self.shadowColor = self.internalCopyOfShadowColor;
            self.internalCopyOfShadowColor = nil;
            self.shadowColorApplied = NO;
        }
        
        if(self.backgroundColorApplied){
            self.backgroundColor = self.internalCopyOfBackgroundColor;
            self.internalCopyOfBackgroundColor = nil;
            self.backgroundColorApplied = NO;
        }
    }
    [self ckSetHighlighted:highlighted];
}

+ (void)load{
    CKSwizzleSelector([UILabel class],@selector(setHighlighted:),@selector(ckSetHighlighted:));
}

@end
