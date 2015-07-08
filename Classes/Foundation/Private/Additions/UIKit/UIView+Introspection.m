//
//  UIView+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UIView+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "UIView+AutoresizingMasks.h"
#import "CKVersion.h"

#import "UIColor+ValueTransformer.h"
#import "UIImage+ValueTransformer.h"
#import "NSNumber+ValueTransformer.h"
#import "NSURL+ValueTransformer.h"
#import "NSDate+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "NSIndexPath+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+CGTypes.h"
#import "CKConfiguration.h"

#import "CKDebug.h"

@implementation UIView (CKIntrospectionAdditions)

- (void)subviewsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.contentType = [UIView class];
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)insertSubviewsObjects:(NSArray *)views atIndexes:(NSIndexSet*)indexes{
	
	NSInteger i = 0;
	NSUInteger currentIndex = [indexes firstIndex];
	while (currentIndex != NSNotFound) {
		UIView* view = [views objectAtIndex:i];
		[self insertSubview:view atIndex:currentIndex];
		currentIndex = [indexes indexGreaterThanIndex: currentIndex];
		++i;
	}
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeSubviewsObjectsAtIndexes:(NSIndexSet*)indexes{
	NSArray* views = [self.subviews objectsAtIndexes:indexes];
	for(UIView* view in views){
		[view removeFromSuperview];
	}
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeAllSubviewsObjects{
	NSArray* views = [NSArray arrayWithArray:self.subviews];
	for(UIView* view in views){
		[view removeFromSuperview];
	}
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)insertMotionEffectsObjects:(NSArray *)effects atIndexes:(NSIndexSet*)indexes{
    
    NSInteger i = 0;
    NSUInteger currentIndex = [indexes firstIndex];
    while (currentIndex != NSNotFound) {
        UIMotionEffect* effect = [effects objectAtIndex:i];
        [self addMotionEffect:effect];
        currentIndex = [indexes indexGreaterThanIndex: currentIndex];
        ++i;
    }
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeMotionEffectsObjectsAtIndexes:(NSIndexSet*)indexes{
    NSArray* effects = [self.motionEffects objectsAtIndexes:indexes];
    for(UIMotionEffect* effect in effects){
        [self removeMotionEffect:effect];
    }
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)removeAllMotionEffectsObjects{
    NSArray* effects = [NSArray arrayWithArray:self.motionEffects];
    for(UIMotionEffect* effect in effects){
        [self removeMotionEffect:effect];
    }
}

- (void)setSubviews:(NSArray *)subviews{
    [self removeAllSubviewsObjects];
    for(id object in subviews){
        UIView* view = nil;
        if([object isKindOfClass:[UIView class]]){
            view = (UIView*)object;
        }else if([object isKindOfClass:[NSDictionary class]]){
            view = [NSValueTransformer objectFromDictionary:object];
        }else{
            CKAssert(NO,@"Non supported format");
        }
        [self addSubview:view];
    }
}

- (void)autoresizingMaskExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKBitMaskDefinition(@"UIViewAutoresizing",
                                                    UIViewAutoresizingNone,
                                                    UIViewAutoresizingFlexibleLeftMargin,
                                                    UIViewAutoresizingFlexibleWidth,
                                                    UIViewAutoresizingFlexibleRightMargin,
                                                    UIViewAutoresizingFlexibleTopMargin,
                                                    UIViewAutoresizingFlexibleHeight,
                                                    UIViewAutoresizingFlexibleBottomMargin,
                                                    UIViewAutoresizingFlexibleAll,
                                                    UIViewAutoresizingFlexibleSize,
                                                    UIViewAutoresizingFlexibleAllMargins,
                                                    UIViewAutoresizingFlexibleHorizontalMargins,
                                                    UIViewAutoresizingFlexibleVerticalMargins);
}

- (void)contentModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
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

+ (NSArray*)additionalClassPropertyDescriptors{
	NSMutableArray* properties = [NSMutableArray array];
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:@"backgroundColor"
																		   withClass:[UIColor class]
																		  assignment:CKClassPropertyDescriptorAssignementTypeCopy
																			readOnly:NO]];
    
    NSString *appliedStyleDescription = nil;
    appliedStyleDescription = @"appliedStyle";
    
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:appliedStyleDescription
																		   withClass:[NSMutableDictionary class]
																		  assignment:CKClassPropertyDescriptorAssignementTypeRetain
																			readOnly:YES]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"bounds"
																		   structName:@"CGRect"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGRect)]
																		   structSize:sizeof(CGRect)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"center"
																		   structName:@"CGPoint"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGPoint)]
																		   structSize:sizeof(CGPoint)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:@"subviews"
																		   withClass:[NSArray class]
																		  assignment:CKClassPropertyDescriptorAssignementTypeCopy
																			readOnly:YES]];
	
	[properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"clearsContextBeforeDrawing"
																		   readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"clipsToBounds"
																		   readOnly:NO]];
    //if([CKOSVersion() floatValue] >= 6){
        [properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"hidden"
                                                                               readOnly:NO]];
    //}
    
	[properties addObject:[CKClassPropertyDescriptor floatDescriptorForPropertyNamed:@"alpha"
																			readOnly:NO]];
    
	[properties addObject:[CKClassPropertyDescriptor intDescriptorForPropertyNamed:@"contentMode"
																		  readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor floatDescriptorForPropertyNamed:@"contentScaleFactor"
																			readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"contentStretch"
																		   structName:@"CGRect"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGRect)]
																		   structSize:sizeof(CGRect)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"frame"
																		   structName:@"CGRect"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGRect)]
																		   structSize:sizeof(CGRect)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor structDescriptorForPropertyNamed:@"transform"
																		   structName:@"CGAffineTransform"
																	   structEncoding:[NSString stringWithUTF8String:@encode(CGAffineTransform)]
																		   structSize:sizeof(CGAffineTransform)
																			 readOnly:NO]];
	[properties addObject:[CKClassPropertyDescriptor intDescriptorForPropertyNamed:@"autoresizingMask"
																		  readOnly:NO]];
    
    [properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:@"motionEffects"
                                                                           withClass:[NSArray class]
                                                                          assignment:CKClassPropertyDescriptorAssignementTypeCopy
                                                                            readOnly:YES]];
	/*
	 @property(nonatomic, getter=isHidden) BOOL hidden
	 */
	
	return properties;
}

@end

