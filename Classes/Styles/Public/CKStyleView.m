//
//  CKStyleView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleView.h"
#import "CKStyleView+Drawing.h"
#import "CKStyleView+Paths.h"
#import "NSObject+Bindings.h"

#import "UIImage+Transformations.h"
#import "NSArray+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import "CKImageCache.h"

#import <QuartzCore/QuartzCore.h>

@interface CKStyleView ()
@property(nonatomic,retain)NSString* maskCacheIdentifier;
@property(nonatomic,retain)UIImageView* maskImageView;

@property(nonatomic,retain)NSString* borderCacheIdentifier;
@property(nonatomic,retain)UIImageView* borderImageView;

@property(nonatomic,retain)UIImageView* backgroundImageView;

@property(nonatomic,retain)NSString* gradientCacheIdentifier;
@property(nonatomic,retain)UIImageView* backgroundGradientView;

@property(nonatomic,retain)NSString* separatorCacheIdentifier;
@property(nonatomic,retain)UIImageView* separatorImageView;

@property(nonatomic,retain)NSString* embossTopCacheIdentifier;
@property(nonatomic,retain)UIImageView* embossTopView;

@property(nonatomic,retain)NSString* embossBottomCacheIdentifier;
@property(nonatomic,retain)UIImageView* embossBottomView;

@property(nonatomic,assign)CGRect lastDrawBounds;
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
    if(self.maskCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.maskCacheIdentifier];
    }
    if(self.borderCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.borderCacheIdentifier];
    }
    if(self.gradientCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.gradientCacheIdentifier];
    }
    if(self.separatorCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.separatorCacheIdentifier];
    }
    
    if(self.embossTopCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.embossTopCacheIdentifier];
    }
    if(self.embossBottomCacheIdentifier){
        [[CKImageCache sharedInstance]unregisterHandler:self withIdentifier:self.embossBottomCacheIdentifier];
    }
    
    
    
    [_backgroundImageView release]; _backgroundImageView = nil;
    [_image release]; _image = nil;
    [_gradientColors release]; _gradientColors = nil;
    [_gradientColorLocations release]; _gradientColorLocations = nil;
    [_borderColor release]; _borderColor = nil;
    [_separatorColor release]; _separatorColor = nil;
    [_embossTopColor release]; _embossTopColor = nil;
    [_embossBottomColor release]; _embossBottomColor = nil;
    [_maskCacheIdentifier release]; _maskCacheIdentifier = nil;
    [_maskImageView release]; _maskImageView = nil;
    [_borderCacheIdentifier release]; _borderCacheIdentifier = nil;
    [_borderImageView release]; _borderImageView = nil;
    [_gradientCacheIdentifier release]; _gradientCacheIdentifier = nil;
    [_backgroundGradientView release]; _backgroundGradientView = nil;
    [_separatorCacheIdentifier release]; _separatorCacheIdentifier = nil;
    [_separatorImageView release]; _separatorImageView = nil;
    [_embossTopCacheIdentifier release]; _embossTopCacheIdentifier = nil;
    [_embossTopView release]; _embossTopView = nil;
    [_embossBottomCacheIdentifier release]; _embossBottomCacheIdentifier = nil;
    [_embossBottomView release]; _embossBottomView = nil;
    [super dealloc];
}


- (void)postInit {
    self.opaque = YES;
    
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.borderLocation = CKStyleViewBorderLocationNone;
    
	self.separatorColor = [UIColor clearColor];
	self.separatorWidth = 1;
	self.separatorLocation = CKStyleViewSeparatorLocationNone;
    
    self.backgroundColor = [UIColor clearColor];
	self.imageContentMode = UIViewContentModeScaleToFill;
    
    self.corners = CKStyleViewCornerTypeNone;
    self.roundedCornerSize = 10;
    
    self.clipsToBounds = 0;
    self.userInteractionEnabled = NO;
    
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
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    if(self.corners != CKStyleViewCornerTypeNone && self.roundedCornerSize != 0){
        if(!self.maskImageView){
            self.maskImageView = [[[UIImageView alloc]initWithFrame:self.bounds]autorelease];
            self.layer.mask = self.maskImageView.layer;
        }
        
        self.maskImageView.image = [self maskImage];
        self.maskImageView.frame = self.bounds;
    }
    
    BOOL hasExtraBackground = NO;
    
    if(self.image ){
        hasExtraBackground = YES;
        if(!self.backgroundImageView){
            self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
            [self addSubview:self.backgroundImageView];
        }
        self.backgroundImageView.contentMode = self.imageContentMode;
        self.backgroundImageView.image = self.image;
        self.backgroundImageView.opaque = YES;
    }else{
        self.backgroundImageView.hidden = YES;
    }
    
    if(self.gradientColors){
        hasExtraBackground = YES;
        if(!self.backgroundGradientView){
            self.backgroundGradientView = [[[UIImageView alloc]initWithFrame:self.bounds]autorelease];
            [self addSubview:self.backgroundGradientView];
        }
        
        self.backgroundGradientView.image = [self gradientImage];
        self.backgroundGradientView.frame = self.bounds;
    }
    
    
    if (self.embossTopColor && (self.embossTopColor != [UIColor clearColor])) {
        if(!self.embossTopView){
            hasExtraBackground = YES;
            self.embossTopView = [[[UIImageView alloc]initWithFrame:self.bounds]autorelease];
            [self addSubview:self.embossTopView];
        }
        
        self.embossTopView.image = [self embossTopImage];
        self.embossTopView.frame = self.bounds;
    }
    
    
    if (self.embossBottomColor && (self.embossBottomColor != [UIColor clearColor])) {
        if(!self.embossBottomView){
            hasExtraBackground = YES;
            self.embossBottomView = [[[UIImageView alloc]initWithFrame:self.bounds]autorelease];
            [self addSubview:self.embossBottomView];
        }
        
        self.embossBottomView.image = [self embossBottomImage];
        self.embossBottomView.frame = self.bounds;
    }
    
    if(self.borderColor!= nil && self.borderColor != [UIColor clearColor] && self.borderWidth > 0 && self.borderLocation != CKStyleViewBorderLocationNone){
        if(!self.borderImageView){
            self.borderImageView = [[[UIImageView alloc]initWithFrame:self.bounds]autorelease];
            [self addSubview:self.borderImageView];
            self.borderImageView.opaque = YES;
        }
        
        self.borderImageView.image = [self borderImage];
        self.borderImageView.frame = self.bounds;
        
        if(!hasExtraBackground){
            self.borderImageView.backgroundColor = self.backgroundColor;
        }
    }
    
    if(self.separatorColor!= nil && self.separatorColor != [UIColor clearColor] && self.separatorWidth > 0 && self.separatorLocation != CKStyleViewSeparatorLocationNone){
        if(!self.separatorImageView){
            self.separatorImageView = [[[UIImageView alloc]initWithFrame:self.bounds]autorelease];
            [self addSubview:self.separatorImageView];
        }
        
        self.separatorImageView.image = [self separatorImage];
        self.separatorImageView.frame = self.bounds;
    }
    
    [self updateDisplay];
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