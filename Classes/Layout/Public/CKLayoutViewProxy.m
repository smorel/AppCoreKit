//
//  CKLayoutViewProxy.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/18/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKLayoutViewProxy.h"


#import "UIView+CKLayout.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "CKPropertyExtendedAttributes.h"
#import "CKStyleManager.h"
#import "CKRuntime.h"
#import "UIView+Name.h"
#import "CKStyleView.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+Style.h"

@interface UIView()
@property(nonatomic,assign,readwrite) UIView* containerLayoutView;
@end

@interface CKLayoutBox()
+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly;
+ (void)performLayoutWithFrame:(CGRect)theframe forBox:(NSObject<CKLayoutBoxProtocol>*)box;
@end

@interface CKLayoutViewProxy()
@property(nonatomic,retain,readwrite) UIView* view;
@end

@implementation CKLayoutViewProxy

- (void)dealloc{
    [_view release];
    [_viewAttributes release];
    [super dealloc];
}

- (UIView*)view{
    if(!self.containerLayoutView)
        return nil;

    if(!_view || ![_view superview] || ([_view superview] != self.containerLayoutView)){
        UIView* container = self.containerLayoutView;
        while(container && !_view){
            self.view = [container viewWithName:self.name];
            UIView* newContainer = [[container containerLayoutBox] containerLayoutView];
            container = (newContainer == container) ? nil : newContainer;
        }
        
        if(_view){
            [self insertViewAtRightPositionInHierarchy:_view];
            _view.containerLayoutBox = self;
        }
    }
    return _view;
}


- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    CGSize viewSize = self.view.hidden ? CGSizeZero : [self.view preferredSizeConstraintToSize:size];
    
    self.lastPreferedSize = self.view.hidden ? CGSizeZero : [CKLayoutBox preferredSizeConstraintToSize:viewSize forBox:self];
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize size = [self preferredSizeConstraintToSize:theframe.size];
    
    [self setBoxFrameTakingCareOfTransform:CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height)];
    
    [self.view performLayoutWithFrame:theframe];
    
    [CKLayoutBox performLayoutWithFrame:self.frame forBox:self];
}

- (void)setBoxFrameTakingCareOfTransform:(CGRect)rect{
    [self.view setBoxFrameTakingCareOfTransform:rect];
}

- (id<CKLayoutBoxProtocol>)layoutWithKeyPath:(NSString*)keypath{
    return [self.view layoutWithKeyPath:keypath];
}

- (id<CKLayoutBoxProtocol>)layoutWithName:(NSString*)thename{
    return [self.view layoutWithName:thename];
}

+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly{
    CKLayoutViewProxy* p = (CKLayoutViewProxy*)box;
    [[p.view class]invalidateLayoutBox:p recursivelly:YES];
    
    [CKLayoutBox invalidateLayoutBox:box recursivelly:recursivelly];
}

- (NSInteger)computeIndexOfInsertionInContainerView{
    //TODO : Insert the view at the right position taking care of the layout !
    //sometimes it's on top of view instead of of being behind
    return self.containerLayoutView.subviews.count;
}

- (void)insertViewAtRightPositionInHierarchy:(UIView*)view{
    //if super view changes, we'll probably have to convert the current frame for current superview to new superview
    if(!self.containerLayoutView)
        return;
    
    [_view invalidateLayout];
    [_view removeFromSuperview];
    
    NSInteger index = [self computeIndexOfInsertionInContainerView];
    [self.containerLayoutView insertSubview:_view atIndex:index];
}

- (void)setupViewAttributes{
    if(self.view && self.viewAttributes){
        [NSValueTransformer transform:self.viewAttributes toObject:_view];
    }
}

- (CGFloat)maximumHeight{
    return self.view.hidden ? 0 : [super maximumHeight];
}

- (CGFloat)maximumWidth{
    return self.view.hidden ? 0 : [super maximumWidth];
}

- (CGFloat)minimumHeight{
    return self.view.hidden ? 0 : [super minimumHeight];
}

- (CGFloat)minimumWidth{
    return self.view.hidden ? 0 : [super minimumWidth];
}

- (CGSize)maximumSize{
    return self.view.hidden ? CGSizeZero : [super maximumSize];
}

- (CGSize)minimumSize{
    return self.view.hidden ? CGSizeZero : [super minimumSize];
}

@end
