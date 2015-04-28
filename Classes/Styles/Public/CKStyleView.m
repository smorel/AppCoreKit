//
//  CKStyleView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleView.h"
#import "CKStyleView+Drawing.h"
#import "CKStyleView+Light.h"

#import "UIImage+Transformations.h"
#import "NSArray+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import "CKImageCache.h"
#import "CKStyleView+Paths.h"

#import <QuartzCore/QuartzCore.h>

@interface CKStyleView ()
@property(nonatomic,retain)UIColor* fillColor;
@property(nonatomic,retain)UIImageView* shadowImageView;

@property(nonatomic,retain)CALayer* highlightLayer;
@property(nonatomic,retain)NSString* highlightGradientCacheIdentifier;
@property(nonatomic,retain)CALayer* highlightGradientLayer;
@property(nonatomic,retain)NSString* highlightMaskCacheIdentifier;
@property(nonatomic,retain)CALayer* highlightMaskLayer;

@property(nonatomic,retain)NSMutableArray* observedViews;
@property(nonatomic,assign)CGRect lastShadowFrame;
@property(nonatomic,assign)CGRect lastHighlightFrame;
@end



@implementation CKStyleView

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

- (void)dealloc {
    NSAssert(_observedViews == nil,@"see shadows management");
    
    if(self.highlightGradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightGradientCacheIdentifier];
    }
    
    
    if(self.highlightMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightMaskCacheIdentifier];
    }
    
    [_observedViews release]; _observedViews = nil;
    [_image release]; _image = nil;
    [_gradientColors release]; _gradientColors = nil;
    [_gradientColorLocations release]; _gradientColorLocations = nil;
    [_borderColor release]; _borderColor = nil;
    [_separatorColor release]; _separatorColor = nil;
    [_fillColor release]; _fillColor = nil;
    [_embossTopColor release]; _embossTopColor = nil;
    [_embossBottomColor release]; _embossBottomColor = nil;
    [_borderShadowColor release]; _borderShadowColor = nil;
    [_shadowImageView release]; _shadowImageView = nil;
    [_highlightColor release]; _highlightColor = nil;
    [_highlightLayer release]; _highlightLayer = nil;
    [_highlightMaskLayer release]; _highlightMaskLayer = nil;
    [_highlightGradientLayer release]; _highlightGradientLayer = nil;
    [_highlightGradientCacheIdentifier release]; _highlightGradientCacheIdentifier = nil;
    [_highlightMaskCacheIdentifier release]; _highlightMaskCacheIdentifier = nil;
    [super dealloc];
}


- (void)postInit {
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.borderLocation = CKStyleViewBorderLocationNone;
    
    self.highlightColor = [UIColor whiteColor];
    self.highlightRadius = 200;
    self.highlightWidth = 0;
    self.highlightEndColor =[UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    
    self.lightPosition = CGPointMake(0,0);
    self.lightIntensity = 20;
    self.lightDirection = CGPointMake(0.5,1);
    
	self.separatorColor = [UIColor clearColor];
	self.separatorWidth = 1;
	self.separatorLocation = CKStyleViewSeparatorLocationNone;
    
	self.fillColor = [UIColor clearColor];
	self.imageContentMode = UIViewContentModeScaleToFill;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.clipsToBounds = 0;
    self.userInteractionEnabled = NO;
    
    _borderShadowRadius = 2;
    _borderShadowOffset = CGSizeMake(0,0);
    
    self.gradientStyle = CKStyleViewGradientStyleVertical;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.separatorInsets = UIEdgeInsetsMake(0,0,0,0);
    
    self.separatorDashPhase = 0;
    self.separatorDashLengths = nil;
    self.separatorLineCap = kCGLineCapButt;
    self.separatorLineJoin = kCGLineJoinMiter;
}

- (void)imageContentModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIViewContentMode",
                                                    UIViewContentModeScaleToFill,
                                                    UIViewContentModeScaleAspectFit,      
                                                    UIViewContentModeScaleAspectFill,    
                                                    UIViewContentModeRedraw,              
                                                    UIViewContentModeCenter,             
                                                    UIViewContentModeTop,
                                                    UIViewContentModeBottom,
                                                    UIViewContentModeLeft,
                                                    UIViewContentModeRight,
                                                    UIViewContentModeTopLeft,
                                                    UIViewContentModeTopRight,
                                                    UIViewContentModeBottomLeft,
                                                    UIViewContentModeBottomRight);
}


- (void)borderLocationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewBorderLocation",
                                                    CKStyleViewBorderLocationNone,
                                                    CKStyleViewBorderLocationTop,
                                                    CKStyleViewBorderLocationBottom,
                                                    CKStyleViewBorderLocationRight,
                                                    CKStyleViewBorderLocationLeft,
                                                    CKStyleViewBorderLocationAll);
}

- (void)separatorLocationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewSeparatorLocation",
                                                    CKStyleViewSeparatorLocationNone,
                                                    CKStyleViewSeparatorLocationTop,
                                                    CKStyleViewSeparatorLocationBottom,
                                                    CKStyleViewSeparatorLocationRight,
                                                    CKStyleViewSeparatorLocationLeft,
                                                    CKStyleViewSeparatorLocationAll);
}

- (void)gradientStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKStyleViewGradientStyle",
                                                    CKStyleViewGradientStyleVertical,
                                                    CKStyleViewGradientStyleHorizontal);
}

- (void)separatorDashLengthsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [NSNumber class];
}

- (void)separatorLineCapExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CGLineCap",
                                                 kCGLineCapButt,
                                                 kCGLineCapRound,
                                                 kCGLineCapSquare);
}

- (void)separatorLineJoinExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CGLineJoin",
                                                 kCGLineJoinMiter,
                                                 kCGLineJoinRound,
                                                 kCGLineJoinBevel);
}


//HACK to control how to paint using the background color !
- (void)setBackgroundColor:(UIColor *)color{
    //self.gradientColors = nil;
    
	self.fillColor = color;
    CGFloat alpha = CGColorGetAlpha([color CGColor]);
    if(self.corners == CKStyleViewCornerTypeNone && alpha >= 1){
        [super setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [super setBackgroundColor:[UIColor clearColor]];
    }
    [self updateDisplay];
}

- (UIColor*)backgroundColor{
    return (self.gradientColors == nil) ? self.fillColor : [UIColor clearColor];
}

- (void)setImage:(UIImage *)anImage {
    if (anImage != _image) {
        [_image release];
        _image = [anImage retain];
        
        self.opaque = YES;
        //self.backgroundColor = [UIColor blackColor];
        [self updateDisplay];
    }
}

- (void)setCorners:(CKStyleViewCornerType)newCorners{
    if(_corners != newCorners){
        _corners = newCorners;
        
        CGFloat alpha = CGColorGetAlpha([_fillColor CGColor]);
        if(newCorners == CKStyleViewCornerTypeNone && alpha >= 1){
            //TODO : if no shadow set opaque color
            //[super setBackgroundColor:[UIColor blackColor]];
            self.opaque = YES;
        }
        else{
            [super setBackgroundColor:[UIColor clearColor]];
            self.opaque = NO;
        }
        [self updateDisplay];
    }
}

- (void)setBorderLocation:(NSInteger)theborderLocation{
    if(_borderLocation != theborderLocation){
        _borderLocation = theborderLocation;
        [self updateDisplay];
    }
}

- (void)setSeparatorLocation:(NSInteger)theseparatorLocation{
    if(_separatorLocation != theseparatorLocation){
        _separatorLocation = theseparatorLocation;
        [self updateDisplay];
    }
}

- (void)setSeparatorInsets:(UIEdgeInsets)theSeparatorInsets{
    if(!UIEdgeInsetsEqualToEdgeInsets(_separatorInsets, theSeparatorInsets)){
        _separatorInsets = theSeparatorInsets;
        [self updateDisplay];
    }
}

- (void)setBorderWidth:(CGFloat)width {
    if(width != _borderWidth){
        _borderWidth = width;
        [self updateDisplay];
    }
}

- (void)updateDisplay{
    [self setNeedsDisplay];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    if([self shadowEnabled]){
        if([self updateShadowOffsetWithLight]){
            UIImage* shadowImage = [self generateShadowImage];
            if(!self.shadowImageView){
                self.shadowImageView = [[UIImageView alloc]initWithImage:shadowImage];
                [self addSubview:self.shadowImageView];
            }else{
                @autoreleasepool {
                    self.shadowImageView.image = shadowImage;
                }
            }
            
            self.shadowImageView.frame = [self shadowImageViewFrame];
        }
    }
    
    if([self highlightEnabled]){
        if([self updateHighlightOffsetWithLight]){
            if(!self.highlightLayer){
                self.highlightLayer = [[[CALayer alloc]init]autorelease];
                [self.layer addSublayer:self.highlightLayer];
            }
            
            if(!self.highlightGradientLayer){
                self.highlightGradientLayer = [[[CALayer alloc]init]autorelease];
                [self.highlightLayer addSublayer:self.highlightGradientLayer];
            }
            
            if(!self.highlightMaskLayer){
                self.highlightMaskLayer = [[[CALayer alloc]init]autorelease];
                self.highlightLayer.mask = self.highlightMaskLayer;
            }
            
            [self updateHighlightGradientLayerContent];
            [self updateHighlightMaskLayerContent];
            [self setupHighlightLayers];
        }

    }
    
    [CATransaction commit];
}

- (UIImage*)highlightGradientImage{
    if(self.highlightGradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightGradientCacheIdentifier];
    }
    
    self.highlightGradientCacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Highlight_Gradient_%f_%@_%@",
                                             self.highlightRadius,self.highlightColor,self.highlightEndColor];
    UIImage* gradientImage = [[CKImageCache sharedInstance]imageWithIdentifier:self.highlightGradientCacheIdentifier];
    if(!gradientImage){
        gradientImage = [UIImage radialGradientImageWithRadius:self.highlightRadius startColor:self.highlightColor endColor:self.highlightEndColor options:0];
    }
    
    [[CKImageCache sharedInstance]registerHandler:self image:gradientImage withIdentifier:self.highlightGradientCacheIdentifier];
    return gradientImage;
}

- (void)updateHighlightGradientLayerContent{
    UIImage* gradientImage = [self highlightGradientImage];
    
    self.highlightGradientLayer.contents = (id)gradientImage.CGImage;
    self.highlightGradientLayer.bounds = CGRectMake(0,0,gradientImage.size.width,gradientImage.size.height);
}

- (UIImage*)highlightMaskImage{
    if(self.highlightMaskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.highlightMaskCacheIdentifier];
    }
    
    self.highlightMaskCacheIdentifier = [NSString stringWithFormat:@"CKStyleView_Highlight_Mask_%lu_%f_%f",
                                             (unsigned long)self.corners,self.roundedCornerSize,self.highlightWidth];
    
    UIImage* maskImage = [[CKImageCache sharedInstance]imageWithIdentifier:self.highlightMaskCacheIdentifier];
    if(!maskImage){
        CGMutablePathRef highlightPath = [CKStyleView generateBorderPathWithBorderLocation:CKStyleViewBorderLocationAll
                                                                               borderWidth:self.highlightWidth
                                                                                cornerType:self.corners
                                                                         roundedCornerSize:self.roundedCornerSize
                                                                                      rect:self.bounds];
        
        maskImage = [UIImage maskImageWithStrokePath:highlightPath width:self.highlightWidth size:self.bounds.size];
        
        CGPathRelease(highlightPath);
    }
    
    [[CKImageCache sharedInstance]registerHandler:self image:maskImage withIdentifier:self.highlightMaskCacheIdentifier];
    return maskImage;
}

- (void)updateHighlightMaskLayerContent{
    UIImage* maskImage = [self highlightMaskImage];
    
    self.highlightMaskLayer.contents = (id)maskImage.CGImage;
}

- (void)regenerateShadow{
    if(![self shadowEnabled])
        return;
    
    @autoreleasepool {
        UIImage* shadowImage = [self generateShadowImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shadowImageView.image = shadowImage;
            self.shadowImageView.frame = [self shadowImageViewFrame];
        });
    }
}

- (void)setupHighlightLayers{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.highlightLayer.frame = [self bounds];
    self.highlightGradientLayer.position = self.highlightCenter;
    self.highlightMaskLayer.frame = self.highlightLayer.bounds;
    
    [CATransaction commit];
}

- (void)regenerateHighlight{
    if(![self highlightEnabled])
        return;
    
    [self setupHighlightLayers];
}

@end


@implementation UIView(CKStyleView)

- (CKStyleView*)styleView{
    if(self.subviews.count == 0)
        return nil;
    
    UIView* first = [self.subviews objectAtIndex:0];
    if([first isKindOfClass:[CKStyleView class]])
        return (CKStyleView*)first;
    
    return nil;
}

@end