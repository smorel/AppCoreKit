//
//  UIViewController+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIViewController+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKRuntime.h"
#import <objc/runtime.h>
#import "CKWeakRef.h"
#import "CKVersion.h"

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

/**
 */
@interface UIViewController (CKLayout)
@end


@implementation UIViewController(CKLayout)

- (void)UIViewController_Layout_loadView{
    [self UIViewController_Layout_loadView];
    if(self.view){
        self.view.containerViewController = self;
        self.view.flexibleSize = YES;
    }
}

+ (void)load{
    CKSwizzleSelector([UIViewController class], @selector(loadView), @selector(UIViewController_Layout_loadView));
}

- (void)setFrame:(CGRect)frame{
    [self.view setFrame:frame];
}

- (CGRect)frame{
    return [self.view frame];
}

static char UIViewControllerNameKey;


- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, &UIViewControllerNameKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)name{
    return objc_getAssociatedObject(self, &UIViewControllerNameKey);
}


- (void)setHidden:(BOOL)hidden{
    [self.view setHidden:hidden];
}

- (BOOL)isHidden{
    return [self.view isHidden];
}

+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly{
    [CKLayoutBox invalidateLayoutBox:box recursivelly:recursivelly];
}

- (id<CKLayoutBoxProtocol>)_layoutWithNameInSelf:(NSString*)name{
    return [self.view _layoutWithNameInSelf:name];
}

- (void)setBoxFrameTakingCareOfTransform:(CGRect)rect{
    [self.view setBoxFrameTakingCareOfTransform:rect];
}

- (void)invalidateLayout{
    [self.view invalidateLayout];
}


- (id<CKLayoutBoxProtocol>)layoutWithName:(NSString*)name{
    return [self.view layoutWithName:name];
}

- (id<CKLayoutBoxProtocol>)layoutWithKeyPath:(NSString*)keypath{
    return [self.view layoutWithKeyPath:keypath];
}

- (void)addLayoutBox:(id<CKLayoutBoxProtocol>)box{
    [self.view addLayoutBox:box];
}

- (void)insertLayoutBox:(id<CKLayoutBoxProtocol>)box atIndex:(NSInteger)index{
    [self.view insertLayoutBox:box atIndex:index];
}

- (void)removeLayoutBox:(id<CKLayoutBoxProtocol>)box{
    [self.view removeLayoutBox:box];
}

- (void)removeAllLayoutBoxes{
    [self.view removeAllLayoutBoxes];
}


- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    return [self.view preferredSizeConstraintToSize:size];
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    [self.view performLayoutWithFrame:theframe];
}

- (NSObject<CKLayoutBoxProtocol>*)rootLayoutBox{
    return self.view.rootLayoutBox;
}

- (void)setInvalidatedLayoutBlock:(CKLayoutBoxInvalidatedBlock)invalidatedLayoutBlock{
    [self.view setInvalidatedLayoutBlock:invalidatedLayoutBlock];
}

- (CKLayoutBoxInvalidatedBlock)invalidatedLayoutBlock{
    return [self.view invalidatedLayoutBlock];
}


- (void)setFixedSize:(CGSize)size{
    [self.view setFixedSize:size];
}

- (void)setLastComputedSize:(CGSize)s{
    [self.view setLastComputedSize:s];
}

- (CGSize)lastComputedSize{
    return [self.view lastComputedSize];
}


- (void)setLastPreferedSize:(CGSize)s{
    [self.view setLastPreferedSize:s];
}

- (CGSize)lastPreferedSize{
    return [self.view lastPreferedSize];
}

- (CGSize)fixedSize{
    return [self.view fixedSize];
}

- (void)setMaximumSize:(CGSize)s{
    [self.view setMaximumSize:s];
}

- (CGSize)maximumSize{
    return [self.view maximumSize];
}

- (void)setMinimumSize:(CGSize)s{
    [self.view setMinimumSize:s];
}

- (CGSize)minimumSize{
    return [self.view minimumSize];
}

- (void)setMargins:(UIEdgeInsets)m{
    [self.view setMargins:m];
}

- (UIEdgeInsets)margins{
    return [self.view margins];
}

- (void)setPadding:(UIEdgeInsets)m{
    [self.view setPadding:m];
}

- (UIEdgeInsets)padding{
    return [self.view padding];
}


- (void)setLayoutBoxes:(CKArrayCollection*)boxes{
    [self.view setLayoutBoxes:boxes];
}

- (CKArrayCollection*)layoutBoxes{
    return [self.view layoutBoxes];
}

- (void)setContainerLayoutBox:(NSObject<CKLayoutBoxProtocol>*)c{
    [self.view setContainerLayoutBox:c];
}

- (NSObject<CKLayoutBoxProtocol>*)containerLayoutBox{
    return [self.view containerLayoutBox];
}

- (UIView*)containerLayoutView{
    return [self.view containerLayoutView];
}



- (void)setMaximumWidth:(CGFloat)f  { [self.view setMaximumWidth:f]; }
- (void)setMaximumHeight:(CGFloat)f { [self.view setMaximumHeight:f]; }
- (void)setMinimumWidth:(CGFloat)f  { [self.view setMinimumWidth:f]; }
- (void)setMinimumHeight:(CGFloat)f { [self.view setMinimumHeight:f]; }
- (void)setFixedWidth:(CGFloat)f    { [self.view setFixedWidth:f]; }
- (void)setFixedHeight:(CGFloat)f   { [self.view setFixedHeight:f]; }
- (void)setMarginLeft:(CGFloat)f    { [self.view setMarginLeft:f]; }
- (void)setMarginTop:(CGFloat)f     { [self.view setMarginTop:f]; }
- (void)setMarginBottom:(CGFloat)f  { [self.view setMarginBottom:f]; }
- (void)setMarginRight:(CGFloat)f   { [self.view setMarginRight:f]; }
- (void)setPaddingLeft:(CGFloat)f   { [self.view setPaddingLeft:f]; }
- (void)setPaddingTop:(CGFloat)f    { [self.view setPaddingTop:f]; }
- (void)setPaddingBottom:(CGFloat)f { [self.view setPaddingBottom:f]; }
- (void)setPaddingRight:(CGFloat)f  { [self.view setPaddingRight:f]; }


- (CGFloat)maximumWidth  { return [self.view maximumWidth]; }
- (CGFloat)maximumHeight { return [self.view maximumHeight]; }
- (CGFloat)minimumWidth  { return [self.view minimumWidth]; }
- (CGFloat)minimumHeight { return [self.view minimumHeight]; }
- (CGFloat)fixedWidth    { return [self.view fixedWidth]; }
- (CGFloat)fixedHeight   { return [self.view fixedHeight]; }
- (CGFloat)marginLeft    { return [self.view marginLeft]; }
- (CGFloat)marginTop     { return [self.view marginTop]; }
- (CGFloat)marginBottom  { return [self.view marginBottom]; }
- (CGFloat)marginRight   { return [self.view marginRight]; }
- (CGFloat)paddingLeft   { return [self.view paddingLeft]; }
- (CGFloat)paddingTop    { return [self.view paddingTop]; }
- (CGFloat)paddingBottom { return [self.view paddingBottom]; }
- (CGFloat)paddingRight  { return [self.view paddingRight]; }

@end




#pragma mark - UIViewController Additions
@interface UIViewController ()
@property (nonatomic,retain)CKWeakRef* containerViewControllerRef;
@end

@implementation UIViewController (CKContainerViewController)

static char CKViewControllerContainerViewControllerKey;

- (void)setContainerViewControllerRef:(CKWeakRef *)ref {
    objc_setAssociatedObject(self,
                             &CKViewControllerContainerViewControllerKey,
                             ref,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKWeakRef *)containerViewControllerRef {
    return objc_getAssociatedObject(self, &CKViewControllerContainerViewControllerKey);
}



- (void)setContainerViewController:(UIViewController *)viewController {
    /*if([self containerViewController] != nil){
        if([self isViewLoaded] && [[self view]superview] != nil){
            
            if(viewController == nil){
                if([CKOSVersion() floatValue] < 5){
                    [self viewWillDisappear:NO];
                }
                
                [[self view]removeFromSuperview];
                
                if([CKOSVersion() floatValue] < 5){
                    [self viewDidDisappear:NO];
                }
            }
        }
    }*/
    
    
    CKWeakRef* ref = self.containerViewControllerRef;
    if(!ref){
        ref = [CKWeakRef weakRefWithObject:viewController];
        objc_setAssociatedObject(self,
                                 &CKViewControllerContainerViewControllerKey,
                                 ref,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else{
        ref.object = viewController;
    }
    
    
    if([CKOSVersion() floatValue] >= 5){
        if(viewController == nil){
            [self removeFromParentViewController];
        }else{
            if(viewController.parentViewController){
                
            }else{
                [viewController addChildViewController:self];
            }
        }
    }
}

- (UIViewController *)containerViewController {
    CKWeakRef* ref = self.containerViewControllerRef;
    return [ref object];
}

@end