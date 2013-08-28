//
//  CKLayoutBox.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBox.h"
#import <objc/runtime.h>
#include <ext/hash_map>
#include <ext/hash_set>
#import <QuartzCore/QuartzCore.h>
#import "CKPropertyExtendedAttributes.h"
#import "CKStyleManager.h"
#import "CKRuntime.h"
#import "UIView+Name.h"
#import "CKStyleView.h"

using namespace __gnu_cxx;

namespace __gnu_cxx{
    template<> struct hash< id >
    {
        size_t operator()( id x) const{
            return (size_t)x;
        }
    };
}


@interface CKLayoutBox()
@property(nonatomic,assign,readwrite) UIView* containerLayoutView;
#ifdef LAYOUT_DEBUG_ENABLED
@property(nonatomic,assign,readwrite) UIView* debugView;
#endif

@end

@implementation CKLayoutBox
@synthesize maximumSize, minimumSize, margins, padding, layoutBoxes = _layoutBoxes,frame,containerLayoutBox,containerLayoutView = _containerLayoutView,verticalAlignment,horizontalAlignment,fixedSize,hidden,
maximumWidth,maximumHeight,minimumWidth,minimumHeight,fixedWidth,fixedHeight,marginLeft,marginTop,marginBottom,marginRight,paddingLeft,paddingTop,paddingBottom,paddingRight,
lastComputedSize,lastPreferedSize,invalidatedLayoutBlock = _invalidatedLayoutBlock, name;

#ifdef LAYOUT_DEBUG_ENABLED
@synthesize debugView;
#endif

- (id)init{
    self = [super init];
    [CKLayoutBox initializeBox:self];
    self.verticalAlignment = CKLayoutVerticalAlignmentCenter;
    self.horizontalAlignment = CKLayoutHorizontalAlignmentCenter;
    self.hidden = NO;
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView = [[[UIView alloc]initWithFrame:CGRectMake(0,0,1,1)]autorelease];
    self.debugView.alpha = 0.4;
    self.debugView.backgroundColor = [UIColor redColor];
    self.debugView.layer.borderColor = [[UIColor redColor]CGColor];
    self.debugView.layer.borderWidth = 1;
#endif
    
    /*
#if TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStylesheets) name:CKCascadingTreeFilesDidUpdateNotification object:nil];
#endif
    */
    
    return self;
}

- (void)dealloc{
    /**
#if TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKCascadingTreeFilesDidUpdateNotification object:nil];
#endif
    */
    
    [_layoutBoxes release];
    [_invalidatedLayoutBlock release];
    [super dealloc];
}

+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly{
    box.lastComputedSize = CGSizeMake(0,0);
    box.lastPreferedSize = CGSizeMake(0,0);
    
    if(recursivelly){
        for(NSObject<CKLayoutBoxProtocol>* subbox in box.layoutBoxes){
            [CKLayoutBox invalidateLayoutBox:subbox recursivelly:YES];
        }
    }
}

- (void)updateStylesheets{
    if(self.containerLayoutBox == nil){
        [CKLayoutBox invalidateLayoutBox:self recursivelly:YES];
        [self.containerLayoutView setNeedsLayout];
    }
}

- (void)invalidateLayout{
    NSObject<CKLayoutBoxProtocol>* l = [self rootLayoutBox];
    if(l && !CGSizeEqualToSize(l.lastComputedSize, CGSizeMake(0,0))){
        [CKLayoutBox invalidateLayoutBox:l recursivelly:YES];
        [l.containerLayoutView setNeedsLayout];
        if(l.invalidatedLayoutBlock){
            l.invalidatedLayoutBlock(l);
        }
    }
}

- (NSObject<CKLayoutBoxProtocol>*)rootLayoutBox{
    NSObject<CKLayoutBoxProtocol>* l = self;
    while(l){
        if(l.containerLayoutBox){
            l = l.containerLayoutBox;
        }else return l;
    }
    return nil;
}

- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index{
    NSInteger i = index;
    NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
    while(i > 0 && box && box.hidden){
        box = [self.layoutBoxes objectAtIndex:(--i)];
    }
    return box.hidden ? nil : box;
}

- (void)verticalAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKLayoutVerticalAlignment",
                                                 CKLayoutVerticalAlignmentTop,
                                                 CKLayoutVerticalAlignmentCenter,
                                                 CKLayoutVerticalAlignmentBottom);
}

- (void)horizontalAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKLayoutHorizontalAlignment",
                                                 CKLayoutHorizontalAlignmentLeft,
                                                 CKLayoutHorizontalAlignmentCenter,
                                                 CKLayoutHorizontalAlignmentRight);
}

+ (void)initializeBox:(NSObject<CKLayoutBoxProtocol>*)box{
    box.maximumSize = CGSizeMake(MAXFLOAT,MAXFLOAT);
    box.minimumSize = CGSizeMake(-MAXFLOAT,-MAXFLOAT);
    box.margins = UIEdgeInsetsMake(0, 0, 0, 0);
    box.padding = UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box{
    CGSize ret = size;
    
    if(box.minimumSize.width  > ret.width) {
        ret.width = box.minimumSize.width;
    }
    if(box.minimumSize.height > ret.height) {
        ret.height = box.minimumSize.height;
    }
    if(box.maximumSize.width  < ret.width) {
        ret.width = box.maximumSize.width;
    }
    if(box.maximumSize.height < ret.height) {
        ret.height = box.maximumSize.height;
    }
    
    return ret;
    //return CGSizeMake(ret.width + box.padding.right + box.padding.left,ret.height+box.padding.top + box.padding.bottom);
}

+ (void)performLayoutWithFrame:(CGRect)theframe forBox:(NSObject<CKLayoutBoxProtocol>*)box{
    for(NSObject<CKLayoutBoxProtocol>* subbox in box.layoutBoxes){
        CGRect boxframe = CGRectMake(theframe.origin.x,
                                     theframe.origin.y,
                                     MAX(0,theframe.size.width),
                                     MAX(0,theframe.size.height));
        [subbox performLayoutWithFrame:boxframe];
    }
}

+ (void)addLayoutBoxes:(NSArray*)boxes toBox:(NSObject<CKLayoutBoxProtocol>*)box{
    
#ifdef LAYOUT_DEBUG_ENABLED
    if([box isKindOfClass:[CKLayoutBox class]]){
        [[box containerLayoutView] addSubview:((CKLayoutBox*)box).debugView];
    }
#endif
    
    for(NSObject<CKLayoutBoxProtocol>* subBox in boxes){
        subBox.containerLayoutBox = box;
        if([subBox isKindOfClass:[CKLayoutBox class]]){
            ((CKLayoutBox*)subBox).containerLayoutView = [box containerLayoutView];
        }else if([subBox isKindOfClass:[UIView class]]){
            UIView* view = (UIView*)subBox;
            view.autoresizingMask = 0;
            if([view superview] != [box containerLayoutView]){
                if([view stylesheet] == nil){
                    NSMutableDictionary* stylesheet = [[box containerLayoutView] stylesheet];
                    [view findAndApplyStyleFromStylesheet:stylesheet propertyName:nil];
                }
                [[box containerLayoutView]addSubview:view];
            }
        }
    }
}

+ (void)removeViewsFromBox:(NSObject<CKLayoutBoxProtocol>*)box recursively:(BOOL)recursively{
    
#ifdef LAYOUT_DEBUG_ENABLED
    if([box isKindOfClass:[CKLayoutBox class]]){
        [((CKLayoutBox*)box).debugView removeFromSuperview];
    }
#endif
    
    for(NSObject<CKLayoutBoxProtocol>* subBox in [box layoutBoxes]){
        if([subBox isKindOfClass:[CKLayoutBox class]]){
            [CKLayoutBox removeViewsFromBox:subBox recursively:YES];
        }else if([subBox isKindOfClass:[UIView class]]){
            UIView* view = (UIView*)subBox;
            [view removeFromSuperview];
        }
    }
}

+ (void)removeLayoutBoxes:(NSArray*)boxes fromBox:(NSObject<CKLayoutBoxProtocol>*)box{
    for(NSObject<CKLayoutBoxProtocol>* subBox in boxes){
        if(subBox.containerLayoutBox == box){
            subBox.containerLayoutBox = nil;
            if([subBox isKindOfClass:[CKLayoutBox class]]){
                ((CKLayoutBox*)subBox).containerLayoutView = nil;
            }
        }
    }
    [CKLayoutBox removeViewsFromBox:box recursively:YES];
}

- (void)setContainerLayoutView:(UIView*)view{
    if(_containerLayoutView != view){
        _containerLayoutView = view;
        
#ifdef LAYOUT_DEBUG_ENABLED
        [_containerLayoutView addSubview:self.debugView];
#endif
        
        for(NSObject<CKLayoutBoxProtocol>* subBox in self.layoutBoxes){
            if([subBox isKindOfClass:[CKLayoutBox class]]){
                ((CKLayoutBox*)subBox).containerLayoutView = [self containerLayoutView];
            }else if([subBox isKindOfClass:[UIView class]]){
                UIView* view = (UIView*)subBox;
                if([view superview] != [self containerLayoutView]){
                    if([view stylesheet] == nil){
                        NSMutableDictionary* stylesheet = [[self containerLayoutView] stylesheet];
                        [view findAndApplyStyleFromStylesheet:stylesheet  propertyName:nil];
                    }
                    [[self containerLayoutView]addSubview:view];
                }
            }
        }
    }
}

- (CGSize)preferedSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    self.lastPreferedSize = [CKLayoutBox preferedSizeConstraintToSize:size forBox:self];
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize size = [self preferedSizeConstraintToSize:theframe.size];
    [self setBoxFrameTakingCareOfTransform:CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height)];
    
    [CKLayoutBox performLayoutWithFrame:self.frame forBox:self];
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView.frame = self.frame;
#endif
}

- (void)setLayoutBoxes:(NSArray*)boxes{
    if(_layoutBoxes){
        [CKLayoutBox removeLayoutBoxes:_layoutBoxes fromBox:self];
    }
    
    [_layoutBoxes release];
    _layoutBoxes = [boxes retain];
    
    if(_layoutBoxes){
        [CKLayoutBox addLayoutBoxes:_layoutBoxes toBox:self];
    }
}

- (void)setFixedSize:(CGSize)size{
    self.maximumSize = size;
    self.minimumSize = size;
}

- (CGSize)fixedSize{
    if(CGSizeEqualToSize(self.maximumSize, self.minimumSize)){
        return self.minimumSize;
    }
    return CGSizeMake(MAXFLOAT, MAXFLOAT);
}


- (void)setMaximumWidth:(CGFloat)f  { self.maximumSize = CGSizeMake(f,self.maximumSize.height); }
- (void)setMaximumHeight:(CGFloat)f { self.maximumSize = CGSizeMake(self.maximumSize.width,f); }
- (void)setMinimumWidth:(CGFloat)f  { self.minimumSize = CGSizeMake(f,self.minimumSize.height); }
- (void)setMinimumHeight:(CGFloat)f { self.minimumSize = CGSizeMake(self.minimumSize.width,f); }
- (void)setFixedWidth:(CGFloat)f    { self.maximumWidth = f; self.minimumWidth = f; }
- (void)setFixedHeight:(CGFloat)f   { self.maximumHeight = f; self.minimumHeight = f; }
- (void)setMarginLeft:(CGFloat)f    { UIEdgeInsets insets = self.margins; insets.left = f; self.margins = insets; }
- (void)setMarginTop:(CGFloat)f     { UIEdgeInsets insets = self.margins; insets.top = f; self.margins = insets; }
- (void)setMarginBottom:(CGFloat)f  { UIEdgeInsets insets = self.margins; insets.bottom = f; self.margins = insets; }
- (void)setMarginRight:(CGFloat)f   { UIEdgeInsets insets = self.margins; insets.right = f; self.margins = insets; }
- (void)setPaddingLeft:(CGFloat)f   { UIEdgeInsets insets = self.padding; insets.left = f; self.padding = insets; }
- (void)setPaddingTop:(CGFloat)f    { UIEdgeInsets insets = self.padding; insets.top = f; self.padding = insets; }
- (void)setPaddingBottom:(CGFloat)f { UIEdgeInsets insets = self.padding; insets.bottom = f; self.padding = insets; }
- (void)setPaddingRight:(CGFloat)f  { UIEdgeInsets insets = self.padding; insets.right = f; self.padding = insets; }


- (CGFloat)maximumWidth  { return self.maximumSize.width; }
- (CGFloat)maximumHeight { return self.maximumSize.height; }
- (CGFloat)minimumWidth  { return self.minimumSize.width; }
- (CGFloat)minimumHeight { return self.minimumSize.height; }
- (CGFloat)fixedWidth    { return (self.maximumWidth == self.minimumWidth) ? self.maximumWidth : MAXFLOAT; }
- (CGFloat)fixedHeight   { return (self.maximumHeight == self.minimumHeight) ? self.maximumHeight : MAXFLOAT; }
- (CGFloat)marginLeft    { return self.margins.left; }
- (CGFloat)marginTop     { return self.margins.top; }
- (CGFloat)marginBottom  { return self.margins.bottom; }
- (CGFloat)marginRight   { return self.margins.right; }
- (CGFloat)paddingLeft   { return self.padding.left; }
- (CGFloat)paddingTop    { return self.padding.top; }
- (CGFloat)paddingBottom { return self.padding.bottom; }
- (CGFloat)paddingRight  { return self.padding.right; }


- (id<CKLayoutBoxProtocol>)_layoutWithNameInSelf:(NSString*)thename{
    for(id<CKLayoutBoxProtocol> layoutBox in self.layoutBoxes){
        if([[layoutBox name]isEqualToString:thename]){
            return layoutBox;
        }
    }
    return nil;
}

- (id<CKLayoutBoxProtocol>)layoutWithName:(NSString*)thename{
    id<CKLayoutBoxProtocol> layoutBox = [self _layoutWithNameInSelf:thename];
    if(layoutBox){
        return layoutBox;
    }
    
    for(id<CKLayoutBoxProtocol> layoutBox in self.layoutBoxes){
        id<CKLayoutBoxProtocol> subLayoutBox = [layoutBox layoutWithName:thename];
        if(subLayoutBox){
            return subLayoutBox;
        }
    }
    
    return nil;
}

- (id<CKLayoutBoxProtocol>)layoutWithKeyPath:(NSString*)keypath{
    id<CKLayoutBoxProtocol> currentBox = self;
    
    NSArray* components = [keypath componentsSeparatedByString:@"."];
    for(NSString* str in components){
        currentBox = [currentBox _layoutWithNameInSelf:str];
        if(!currentBox)
            return nil;
    }
    
    return currentBox;
}

- (void)setBoxFrameTakingCareOfTransform:(CGRect)rect{
    self.frame = rect;
}

@end
