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
#import "CKCascadingTree.h"
#import "UIView+CKLayout.h"
#import "UIViewController+CKLayout.h"
#import "CKLayoutFlexibleSpace.h"

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
@synthesize maximumSize = _maximumSize, minimumSize = _minimumSize, margins = _margins, padding = _padding, layoutBoxes = _layoutBoxes,frame,containerLayoutBox,containerLayoutView = _containerLayoutView,verticalAlignment,horizontalAlignment,fixedSize,hidden,
maximumWidth,maximumHeight,minimumWidth,minimumHeight,fixedWidth,fixedHeight,marginLeft,marginTop,marginBottom,marginRight,paddingLeft,paddingTop,paddingBottom,paddingRight,
lastComputedSize,lastPreferedSize,invalidatedLayoutBlock = _invalidatedLayoutBlock, name, containerViewController,flexibleWidth = _flexibleWidth, flexibleHeight = _flexibleHeight;

#ifdef LAYOUT_DEBUG_ENABLED
@synthesize debugView;
#endif


+ (void)load{
    [CKCascadingTree registerAlias:@"layoutBoxes" forKey:@"layout"];
    
    [CKCascadingTree registerTransformer:^(NSString* containerKey, NSMutableDictionary *container, NSString *key, id value) {
        //We have "<view_classname>" : [ <layoutboxes> ]
        [container removeObjectForKey:key];
        [container setObject:key forKey:@"@class"];
        [container setObject:[NSMutableArray arrayWithArray:value] forKey:@"layoutBoxes"];
    } forPredicate:^BOOL(NSString* containerKey, NSMutableDictionary *container, NSString *key, id value) {
        Class type = NSClassFromString(key);
        if(type
           && ([NSObject isClass:type kindOfClass:[UIView class]] || [NSObject isClass:type kindOfClass:[UIViewController class]] || [NSObject isClass:type kindOfClass:[CKLayoutBox class]])
           && [value isKindOfClass:[NSArray class]]){
            return YES;
        }
           return NO;
    }];
    
    [CKCascadingTree registerTransformer:^(NSString* containerKey, NSMutableDictionary *container, NSString *key, id value) {
        //We have "<view_classname>" : "<name>"
        [container removeObjectForKey:key];
        [container setObject:key forKey:@"@class"];
        [container setObject:value forKey:@"name"];
    } forPredicate:^BOOL(NSString* containerKey, NSMutableDictionary *container, NSString *key, id value) {
        Class type = NSClassFromString(key);
        
        id classDefinition = [container objectForKey:@"@class"];
        id nameDefinition  = [container objectForKey:@"name"];
            
        if(type
           && ([NSObject isClass:type kindOfClass:[UIView class]] || [NSObject isClass:type kindOfClass:[UIViewController class]] || [NSObject isClass:type kindOfClass:[CKLayoutBox class]])
           && [value isKindOfClass:[NSString class]]
           && classDefinition == nil
           && nameDefinition == nil){
            return YES;
        }
        return NO;
    }];
}


- (void)performLayoutBoxesBatchUpdates:(void(^)())updates duration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion{
    if(updates) { updates(); }
    if(CGSizeEqualToSize(CGSizeZero, self.lastComputedSize)){
        if(completion){ completion(YES); }
        return;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.containerLayoutView layoutSubviews];
    } completion:completion];
}

- (id)init{
    self = [super init];
    [CKLayoutBox initializeBox:self];
    self.verticalAlignment = CKLayoutVerticalAlignmentCenter;
    self.horizontalAlignment = CKLayoutHorizontalAlignmentCenter;
    self.hidden = NO;
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView = [[[UIView alloc]initWithFrame:CGRectMake(0,0,1,1)]autorelease];
    self.debugView.alpha = 0.4;
    self.debugView.backgroundColor = [UIColor blueColor];
    self.debugView.layer.borderColor = [[UIColor blueColor]CGColor];
    self.debugView.layer.borderWidth = 2;
    self.debugView.userInteractionEnabled = NO;
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
    
    self.containerLayoutView = nil;
    self.containerLayoutBox = nil;
    self.invalidatedLayoutBlock = nil;
    
    //[self removeAllLayoutBoxes];
    
    [_layoutBoxes release];
    
    [super dealloc];
}

+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly{
    box.lastComputedSize = CGSizeMake(0,0);
    box.lastPreferedSize = CGSizeMake(0,0);
    
    if(recursivelly){
        for(NSObject<CKLayoutBoxProtocol>* subbox in box.layoutBoxes){
            [[subbox class] invalidateLayoutBox:subbox recursivelly:YES];
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

- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index includingFexiSpace:(BOOL)includingFexiSpace{
    NSInteger i = index;
    NSObject<CKLayoutBoxProtocol>* box = [self.layoutBoxes objectAtIndex:i];
    
    while(i >= 0 && box && (box.hidden || (!includingFexiSpace && [box isKindOfClass:[CKLayoutFlexibleSpace class]]) )){
        NSObject<CKLayoutBoxProtocol>* theBox = [self.layoutBoxes objectAtIndex:i];
        if(includingFexiSpace || ![theBox isKindOfClass:[CKLayoutFlexibleSpace class]]){
            box = theBox;
        }
        --i;
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

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box{
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


- (void)layoutWillMoveToWindow:(UIWindow*)newWindow{
    [[self class]layoutWillMoveToWindow:newWindow forBox:self];
}

+ (void)layoutWillMoveToWindow:(UIWindow*)window forBox:(NSObject<CKLayoutBoxProtocol>*)box{
    for(NSObject<CKLayoutBoxProtocol>* subbox in box.layoutBoxes){
        if([subbox isKindOfClass:[UIViewController class]]){
            UIViewController* viewController = (UIViewController*)subbox;
        }
        
        [subbox layoutWillMoveToWindow:window];
    }
}

- (void)addLayoutBox:(id<CKLayoutBoxProtocol>)box{
    CKArrayCollection* mm = (CKArrayCollection*)[self layoutBoxes];
    NSInteger index = [mm indexOfObjectIdenticalTo:box];
    if(index != NSNotFound && box.containerLayoutView &&  (box.containerLayoutBox == self)){
        [self invalidateLayout];
        return;
    }
    
    if(!mm){
        self.layoutBoxes = [CKArrayCollection collection];
        mm = (CKArrayCollection*)[self layoutBoxes];
    }
    
    [box removeFromSuperLayoutBox];
    
    [mm addObject:box];
    
    [CKLayoutBox addLayoutBoxes:@[box] toBox:self];
    [self invalidateLayout];
}


- (void)insertLayoutBox:(id<CKLayoutBoxProtocol>)box atIndex:(NSInteger)index{
    CKArrayCollection* mm = (CKArrayCollection*)[self layoutBoxes];
    if(!mm){
        self.layoutBoxes = [CKArrayCollection collection];
        mm = (CKArrayCollection*)[self layoutBoxes];
    }
    
    [box removeFromSuperLayoutBox];
    
    [mm insertObject:box atIndex:index];
    
    [CKLayoutBox addLayoutBoxes:@[box] toBox:self];
    [self invalidateLayout];

}

- (void)removeLayoutBox:(id<CKLayoutBoxProtocol>)box{
    CKArrayCollection* mm = (CKArrayCollection*)[self layoutBoxes];
    [mm removeObject:box];
    
    [CKLayoutBox removeLayoutBoxes:@[box] fromBox:self];
    [self invalidateLayout];
}

- (void)removeAllLayoutBoxes{
    NSArray* boxes = [[self layoutBoxes]allObjects];
    [[self layoutBoxes]removeAllObjects];
    
    [CKLayoutBox removeLayoutBoxes:boxes fromBox:self];
    [self invalidateLayout];
}

- (void)removeFromSuperLayoutBox{
    if(!self.containerLayoutBox)
        return;
    
    [self.containerLayoutBox removeLayoutBox:self];
}

+ (void)addLayoutBoxes:(NSArray*)boxes toBox:(NSObject<CKLayoutBoxProtocol>*)box{
    
#ifdef LAYOUT_DEBUG_ENABLED
    if([box isKindOfClass:[CKLayoutBox class]]){
        [[box containerLayoutView] addSubview:((CKLayoutBox*)box).debugView];
    }
#endif
    
    for(NSObject<CKLayoutBoxProtocol>* subBox in boxes){
        if(box.containerLayoutView){
            //Sets this here so that stylesmanager can be found relative to the controller that contains the added one.
            if([subBox isKindOfClass:[UIViewController class]]){
                UIViewController* viewController = (UIViewController*)subBox;
                viewController.containerViewController = [[box containerLayoutView]containerViewController];
            }
            
            subBox.containerLayoutBox = box;
        }
        
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
        }else if([subBox isKindOfClass:[UIViewController class]]){
            UIViewController* viewController = (UIViewController*)subBox;
            
            if(box.containerLayoutView){
                UIView* view = viewController.view;
                view.autoresizingMask = 0;
                if([view superview] != [box containerLayoutView]){
                    
                    [viewController viewWillAppear:NO];
                    
                    if([view stylesheet] == nil){
                        NSMutableDictionary* stylesheet = [[box containerLayoutView] stylesheet];
                        [view findAndApplyStyleFromStylesheet:stylesheet propertyName:nil];
                    }
                    [[box containerLayoutView]addSubview:view];
                    
                    [viewController viewDidAppear:NO];
                    
                }
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
    
    if([box isKindOfClass:[UIView class]]){
        UIView* view = (UIView*)box;
        [view removeFromSuperview];
        return;
    }else if([box isKindOfClass:[UIViewController class]]){
        UIViewController* viewController = (UIViewController*)box;
        UIView* view = viewController.view;
        if([box containerLayoutView]){
            [viewController viewWillDisappear:NO];
            [view removeFromSuperview];
            [viewController viewDidDisappear:NO];
        }
        return;
    }
    
    for(NSObject<CKLayoutBoxProtocol>* subBox in [box layoutBoxes]){
        [self removeViewsFromBox:subBox recursively:YES];
    }
}

+ (void)removeLayoutBoxes:(NSArray*)boxes fromBox:(NSObject<CKLayoutBoxProtocol>*)box{
    for(NSObject<CKLayoutBoxProtocol>* subBox in boxes){
        [CKLayoutBox removeViewsFromBox:subBox recursively:YES];
        if(subBox.containerLayoutBox == box){
            subBox.containerLayoutBox = nil;
            if([subBox isKindOfClass:[CKLayoutBox class]]){
                ((CKLayoutBox*)subBox).containerLayoutView = nil;
            }
        }
    }
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
            }else if([subBox isKindOfClass:[UIViewController class]]){
                UIViewController* viewController = (UIViewController*)subBox;
                viewController.containerViewController = [[self containerLayoutView]containerViewController];
                
                UIView* view = viewController.view;
                view.autoresizingMask = 0;
                //TODO : verify if needs to call view will disappear did disappear
                if([view superview] != [self containerLayoutView]){
                    
                    [viewController viewWillAppear:NO];
                    
                    if([view stylesheet] == nil){
                        NSMutableDictionary* stylesheet = [[self containerLayoutView] stylesheet];
                        [view findAndApplyStyleFromStylesheet:stylesheet  propertyName:nil];
                    }
                    [[self containerLayoutView]addSubview:view];
                    
                    [viewController viewDidAppear:NO];
                    
                }
                
            }
            
            subBox.containerLayoutBox = self;
        }
    }
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    self.lastPreferedSize = [CKLayoutBox preferredSizeConstraintToSize:size forBox:self];
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize size = [self preferredSizeConstraintToSize:theframe.size];
    [self setBoxFrameTakingCareOfTransform:CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height)];
    
    [CKLayoutBox performLayoutWithFrame:self.frame forBox:self];
}

- (void)setLayoutBoxes:(CKArrayCollection*)boxes{
    if(_layoutBoxes){
        [CKLayoutBox removeLayoutBoxes:[_layoutBoxes allObjects] fromBox:self];
    }
    
    [_layoutBoxes release];
    _layoutBoxes = [boxes retain];
    
    if(_layoutBoxes){
        [CKLayoutBox addLayoutBoxes:[_layoutBoxes allObjects] toBox:self];
    }
    
    [self invalidateLayout];
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

- (void)setMaximumSize:(CGSize)s   { _maximumSize = s; [self invalidateLayout]; }
- (void)setMinimumSize:(CGSize)s   { _minimumSize = s; [self invalidateLayout]; }
- (void)setMargins:(UIEdgeInsets)m { _margins = m; [self invalidateLayout]; }
- (void)setPadding:(UIEdgeInsets)p { _padding = p; [self invalidateLayout]; }

- (void)setMaximumWidth:(CGFloat)f  { self.maximumSize = CGSizeMake(f,self.maximumSize.height);  }
- (void)setMaximumHeight:(CGFloat)f { self.maximumSize = CGSizeMake(self.maximumSize.width,f); }
- (void)setMinimumWidth:(CGFloat)f  { self.minimumSize = CGSizeMake(f,self.minimumSize.height);}
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

- (void)setFlexibleSize:(BOOL)flexibleSize{
    self.flexibleHeight = flexibleSize; self.flexibleWidth = flexibleSize;
}

- (BOOL)flexibleSize{ return self.flexibleWidth && self.flexibleHeight; }

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
    if( CGRectEqualToRect(self.frame, rect))
        return;
    
    self.frame = rect;
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView.frame = self.frame;
#endif
}

- (UIViewController*)containerViewController{
    return self.containerLayoutView.containerViewController;
}

@end
