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
#import "NSObject+Bindings.h"

@interface CKHighlightView()<CKSharedDisplayLinkDelegate>
@property(nonatomic,retain)NSString* highlightGradientCacheIdentifier;
@property(nonatomic,retain)UIImageView* highlightGradientLayer;
@property(nonatomic,retain)NSString* highlightMaskCacheIdentifier;
@property(nonatomic,retain)UIImageView* highlightMaskLayer;

@property(nonatomic,assign)CGRect lastFrameInWindow;
@end



@implementation CKHighlightView

- (void)dealloc {
    [self clearBindingsContextWithScope:@"Light"];
    [CKSharedDisplayLink unregisterHandler:self];
    
    if(self.highlightGradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightGradientCacheIdentifier];
    }
    
    
    if(self.highlightMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightMaskCacheIdentifier];
    }
    
    [_highlightColor release]; _highlightColor = nil;
    [_highlightMaskLayer release]; _highlightMaskLayer = nil;
    [_highlightGradientLayer release]; _highlightGradientLayer = nil;
    [_highlightGradientCacheIdentifier release]; _highlightGradientCacheIdentifier = nil;
    [_highlightMaskCacheIdentifier release]; _highlightMaskCacheIdentifier = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        [self postInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self postInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self postInit];
    }
    return self;
}

- (void)postInit {
    self.highlightColor = [UIColor whiteColor];
    self.highlightRadius = 200;
    self.highlightWidth = 0;
    self.highlightEndColor =[UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.clipsToBounds = 1;
    self.userInteractionEnabled = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    // [CATransaction begin];
    // [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self updateLights];
    [self layoutHighlightLayers];
    //[CATransaction commit];
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
    
    for(NSInteger i = self.subviews.count - 1; i >= 0; --i){
        UIView* view =[self.subviews objectAtIndex:i];
        if([view isKindOfClass:[CKHighlightView class]])
            return (CKHighlightView*)view;
    }
    
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