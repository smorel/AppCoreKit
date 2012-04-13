//
//  CKUIView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"

@implementation UIView (CKIntrospectionAdditions)

- (void)subviewsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.contentType = [UIView class];
}

//informal protocol for CKProperty arrays insert/remove
//will get call when acting in property grids or table views ...
- (void)insertSubviewsObjects:(NSArray *)views atIndexes:(NSIndexSet*)indexes{
	
	int i = 0;
	unsigned currentIndex = [indexes firstIndex];
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

- (void)autoresizingMaskExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKBitMaskDefinition(@"UIViewAutoresizing",
                                                    UIViewAutoresizingNone,
                                                    UIViewAutoresizingFlexibleLeftMargin,
                                                    UIViewAutoresizingFlexibleWidth,
                                                    UIViewAutoresizingFlexibleRightMargin,
                                                    UIViewAutoresizingFlexibleTopMargin,
                                                    UIViewAutoresizingFlexibleHeight,
                                                    UIViewAutoresizingFlexibleBottomMargin);
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
	[properties addObject:[CKClassPropertyDescriptor classDescriptorForPropertyNamed:@"appliedStyle"
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
	
	/*
	 @property(nonatomic, getter=isHidden) BOOL hidden
	 */
	
	return properties;
}

@end

