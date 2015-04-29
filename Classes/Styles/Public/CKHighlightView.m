//
//  CKHighlightView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-29.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKHighlightView.h"
#import "CKSharedDisplayLink.h"
#import "CKImageCache.h"
#import "CKHighlightView+Highlight.h"
#import "CKHighlightView+Light.h"
#import "CKRuntime.h"

@interface CKHighlightView()<CKSharedDisplayLinkDelegate>
@property(nonatomic,retain)CALayer* highlightLayer;
@property(nonatomic,retain)NSString* highlightGradientCacheIdentifier;
@property(nonatomic,retain)CALayer* highlightGradientLayer;
@property(nonatomic,retain)NSString* highlightMaskCacheIdentifier;
@property(nonatomic,retain)CALayer* highlightMaskLayer;

@property(nonatomic,assign)CGRect lastFrameInWindow;
@end



@implementation CKHighlightView

- (void)dealloc {
    [CKSharedDisplayLink unregisterHandler:self];
    
    if(self.highlightGradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightGradientCacheIdentifier];
    }
    
    
    if(self.highlightMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightMaskCacheIdentifier];
    }
    
    [_highlightColor release]; _highlightColor = nil;
    [_highlightLayer release]; _highlightLayer = nil;
    [_highlightMaskLayer release]; _highlightMaskLayer = nil;
    [_highlightGradientLayer release]; _highlightGradientLayer = nil;
    [_highlightGradientCacheIdentifier release]; _highlightGradientCacheIdentifier = nil;
    [_highlightMaskCacheIdentifier release]; _highlightMaskCacheIdentifier = nil;
    [super dealloc];
}


- (void)postInit {
    self.highlightColor = [UIColor whiteColor];
    self.highlightRadius = 200;
    self.highlightWidth = 0;
    self.highlightEndColor =[UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    
    self.lightPosition = CGPointMake(0,0);
    self.lightIntensity = 20;
    self.lightDirection = CGPointMake(0.5,1);
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.clipsToBounds = 1;
    self.userInteractionEnabled = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self updateLights];
    [self layoutHighlightLayers];
    [CATransaction commit];
    
}


+ (void)load{
    CKSwizzleSelector([UIView class], @selector(addSubview:), @selector(CKHighlightView_addSubview:));
    CKSwizzleSelector([UIView class], @selector(insertSubview:atIndex:), @selector(CKHighlightView_insertSubview:atIndex:));
    CKSwizzleSelector([UIView class], @selector(insertSubview:belowSubview:), @selector(CKHighlightView_insertSubview:belowSubview:));
    CKSwizzleSelector([UIView class], @selector(insertSubview:aboveSubview:), @selector(CKHighlightView_insertSubview:aboveSubview:));
}

@end



@implementation UIView(CKHighlightView)

- (CKHighlightView*)highlightView{
    if(self.subviews.count == 0)
        return nil;
    
    UIView* last = [self.subviews objectAtIndex:self.subviews.count - 1];
    if([last isKindOfClass:[CKHighlightView class]])
        return (CKHighlightView*)last;
    
    return nil;
}

- (void)CKHighlightView_insertSubview:(UIView *)view atIndex:(NSInteger)index{
    [self CKHighlightView_insertSubview:view atIndex:index];
    if([self highlightView]){
        [self bringSubviewToFront:[self highlightView]];
    }
}

- (void)CKHighlightView_insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview{
    [self CKHighlightView_insertSubview:view belowSubview:siblingSubview];
    if([self highlightView]){
        [self bringSubviewToFront:[self highlightView]];
    }
}

- (void)CKHighlightView_insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview{
    [self CKHighlightView_insertSubview:view aboveSubview:siblingSubview];
    if([self highlightView]){
        [self bringSubviewToFront:[self highlightView]];
    }
}

- (void)CKHighlightView_addSubview:(UIView*)view{
    [self CKHighlightView_addSubview:view];
    if([self highlightView]){
        [self bringSubviewToFront:[self highlightView]];
    }
}


@end