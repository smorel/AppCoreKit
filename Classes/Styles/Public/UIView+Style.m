//
//  UIView+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UIView+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"

#import "UILabel+Style.h"
#import "CKLocalization.h"
#import "CKHighlightView.h"
#import "CKShadowView.h"
#import "CKShadeView.h"

#import "CKDebug.h"
#import <objc/runtime.h>
#import "CKVersion.h"
#import "UIView+Name.h"

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


//NSMutableSet* reserverKeyWords = nil;

NSString* CKStyleBackgroundColor = @"backgroundColor";
NSString* CKStyleBackgroundGradientColors = @"backgroundGradientColors";
NSString* CKStyleBackgroundGradientLocations = @"backgroundGradientLocations";
NSString* CKStyleBackgroundImage = @"backgroundImage";
NSString* CKStyleCornerStyle = @"cornerStyle";
NSString* CKStyleCornerSize = @"cornerSize";
NSString* CKStyleAlpha = @"alpha";
NSString* CKStyleContentMode = @"contentMode";
NSString* CKStyleClipsToBounds = @"clipsToBounds";
NSString* CKStyleBackgroundImageContentMode = @"backgroundImageContentMode";

NSString* CKStyleHighlightColor = @"highlightColor";
NSString* CKStyleHighlightEndColor = @"highlightEndColor";
NSString* CKStyleHighlightWidth= @"highlightWidth";
NSString* CKStyleHighlightRadius= @"highlightRadius";


NSString* CKStyleBorderColor = @"borderColor";
NSString* CKStyleBorderWidth = @"borderWidth";
NSString* CKStyleBorderStyle = @"borderStyle";

NSString* CKStyleSeparatorColor = @"separatorColor";
NSString* CKStyleSeparatorWidth = @"separatorWidth";
NSString* CKStyleSeparatorStyle = @"separatorStyle";

NSString* CKStyleBorderShadowColor = @"shadowColor";

NSString* CKStyleViewDescription = @"@views";
NSString* CKStyleAutoLayoutConstraints = @"@constraints";
NSString* CKStyleAutoLayoutFormatOption = @"@options";
NSString* CKStyleAutoLayoutFormat = @"@format";
NSString* CKStyleAutoLayoutHugging = @"@hugging";
NSString* CKStyleAutoLayoutCompression = @"@compression";


@implementation NSMutableDictionary (CKViewStyle)

- (UIColor*)backgroundColor{
	return [self colorForKey:CKStyleBackgroundColor];
}

- (NSArray*)backgroundGradientColors{
	return [self colorArrayForKey:CKStyleBackgroundGradientColors];
}

- (NSArray*)backgroundGradientLocations{
	return [self cgFloatArrayForKey:CKStyleBackgroundGradientLocations];
}

- (UIImage*)backgroundImage{
	return [self imageForKey:CKStyleBackgroundImage];
} 

- (UIViewContentMode)contentMode{
	return (UIViewContentMode)[self enumValueForKey:CKStyleContentMode 
                                 withEnumDescriptor:CKEnumDefinition(@"UIViewContentMode",
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
																	 UIViewContentModeBottomRight)];
    
}

- (UIViewContentMode)backgroundImageContentMode{
	return (UIViewContentMode)[self enumValueForKey:CKStyleBackgroundImageContentMode 
									 withEnumDescriptor:CKEnumDefinition(@"UIViewContentMode",
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
																	 UIViewContentModeBottomRight)];
							   
}

- (CKViewCornerStyle)cornerStyle{
	return (CKViewCornerStyle)[self enumValueForKey:CKStyleCornerStyle 
									 withEnumDescriptor:CKEnumDefinition(@"CKViewCornerStyle",
                                                                     CKViewCornerStyleTableViewCell, 
																	 CKViewCornerStyleRounded,
																	 CKViewCornerStyleRoundedTop,
																	 CKViewCornerStyleRoundedBottom, 
																	 CKViewCornerStylePlain)];
}

- (BOOL)clipsToBounds{
	return [self boolForKey:CKStyleClipsToBounds];
}

- (CGFloat)cornerSize{
	return [self cgFloatForKey:CKStyleCornerSize];
}

- (CGFloat)alpha{
	return [self cgFloatForKey:CKStyleAlpha];
}

- (UIColor*)borderColor{
	return [self colorForKey:CKStyleBorderColor];
}

- (CGFloat)borderWidth{
	return [self cgFloatForKey:CKStyleBorderWidth];
}

- (CKViewBorderStyle)borderStyle{
	return (CKViewBorderStyle)[self enumValueForKey:CKStyleBorderStyle 
									 withEnumDescriptor:CKBitMaskDefinition(@"CKViewBorderStyle",
                                                                            CKViewBorderStyleTableViewCell,
                                                                            CKViewBorderStyleAll,
                                                                            CKViewBorderStyleNone,
                                                                            CKViewBorderStyleTop,
                                                                            CKViewBorderStyleBottom,
                                                                            CKViewBorderStyleLeft,
                                                                            CKViewBorderStyleRight)];
}

- (UIColor*)separatorColor{
	return [self colorForKey:CKStyleSeparatorColor];
}

- (CGFloat)separatorWidth{
	return [self cgFloatForKey:CKStyleSeparatorWidth];
}

- (CKViewSeparatorStyle)separatorStyle{
	return (CKViewSeparatorStyle)[self enumValueForKey:CKStyleSeparatorStyle 
                                 withEnumDescriptor:CKBitMaskDefinition(@"CKViewSeparatorStyle",
                                                                     CKViewSeparatorStyleTableViewCell,
                                                                     CKViewSeparatorStyleTop,
                                                                     CKViewSeparatorStyleBottom,
                                                                     CKViewSeparatorStyleLeft,
                                                                     CKViewSeparatorStyleRight)];
}


- (NSString*)lightStyleDescriptionWithIndentation:(NSInteger)indentation{
    NSMutableSet* cascadingTreeReservedKeys = [NSMutableSet set];
    [NSObject updateReservedKeyWords:cascadingTreeReservedKeys];
    
    NSMutableString* indentationString = [NSMutableString string];
    for(int i =0; i< indentation; ++i){
        [indentationString appendString:@"    "];
    }
    
    NSMutableString* str = [NSMutableString string];
    for(id key in [self allKeys]){
        if(![cascadingTreeReservedKeys containsObject:key] ){
            id object = [self objectForKey:key];
            if([str length] > 0){
                [str appendString:@"\n"];
            }
            if(![object isKindOfClass:[NSMutableDictionary class]]){
                [str appendFormat:@"%@%@ : %@",indentationString,key,object];
            }
            else{
                [str appendFormat:@"%@%@ : {\n%@ \n%@}",indentationString,key,[object lightStyleDescriptionWithIndentation:(indentation + 1)],indentationString];
            }
        }
    }
    return str;
}


- (NSArray*)instanceOfViews{
    //TODO
    if([self containsObjectForKey:CKStyleViewDescription]){
        NSArray* ar = [self objectForKey:CKStyleViewDescription];
        NSMutableArray* views = [NSMutableArray array];
        for(id object in ar){
            UIView* view = nil;
            if([object isKindOfClass:[UIView class]]){
                view = (UIView*)object;
            }else if([object isKindOfClass:[NSDictionary class]]){
                view = [NSValueTransformer objectFromDictionary:object];
            }else{
                CKAssert(NO,@"Non supported format");
            }
            [views addObject:view];
        }
        return views;
    }
    return nil;
}

@end

@implementation UIView (CKStyle)


+ (CKStyleView*)styleView:(UIView*)view{
	if([view isKindOfClass:[CKStyleView class]])
		return (CKStyleView*)view;
	
	for(UIView* subView in [view subviews]){
		if([subView isKindOfClass:[CKStyleView class]])
			return (CKStyleView*)subView;
	}
	return nil;
}

+ (BOOL)needStyleView:(NSMutableDictionary*)style forView:(UIView*)view{
	if(style == nil || [style isEmpty] == YES)
		return NO;

	if([style containsObjectForKey:CKStyleBackgroundGradientColors]
	   || [style containsObjectForKey:CKStyleCornerStyle]
	   || [style containsObjectForKey:CKStyleCornerSize]
	   || [style containsObjectForKey:CKStyleBackgroundImage]
	   || [style containsObjectForKey:CKStyleBorderColor]
	   || ([style containsObjectForKey:CKStyleSeparatorColor] && ![view isKindOfClass:[UITableView class]])){
		return YES;
	}
	return NO;
}

+ (BOOL)needHighlightView:(NSMutableDictionary*)style forView:(UIView*)view{
    if(style == nil || [style isEmpty] == YES)
        return NO;
    
    if([style containsObjectForKey:CKStyleHighlightColor]
       || [style containsObjectForKey:CKStyleHighlightEndColor]
       || [style containsObjectForKey:CKStyleHighlightWidth]
       || [style containsObjectForKey:CKStyleHighlightRadius]){
        return YES;
    }
    return NO;
}

+ (BOOL)needShadowView:(NSMutableDictionary*)style forView:(UIView*)view{
    if(style == nil || [style isEmpty] == YES)
        return NO;
    
    if([style containsObjectForKey:CKStyleBorderShadowColor]){
        return YES;
    }
    return NO;
}

+ (BOOL)needShadeView:(NSMutableDictionary*)style forView:(UIView*)view{
    if(style == nil || [style isEmpty] == YES)
        return NO;
    
    if([style containsObjectForKey:@"shadeColor"]
       || [style containsObjectForKey:@"fullShadeZ"]
       || [style containsObjectForKey:@"noShadeZ"]){
        return YES;
    }
    return NO;
}

- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style{
	return [self applyStyle:style propertyName:nil];
}

- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style propertyName:(NSString*)propertyName{
	NSMutableDictionary* myViewStyle = [style styleForObject:self propertyName:propertyName];
	[[self class] applyStyle:myViewStyle toView:self appliedStack:[NSMutableSet set] delegate:nil];
    return myViewStyle;
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:propertyName];
	return [[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack  delegate:nil];
}

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
    [super updateReservedKeyWords:keyWords];
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleBackgroundColor,CKStyleBackgroundGradientColors,CKStyleBackgroundGradientLocations,CKStyleBackgroundImageContentMode,
								   CKStyleBackgroundImage,CKStyleCornerStyle,CKStyleCornerSize,CKStyleAlpha,CKStyleBorderColor,CKStyleBorderWidth,CKStyleBorderStyle,@"@class",nil]];
}

//if appliedStack is nil, the style is not applicated hierarchically !
+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack
                   delegate:(id)delegate {
	if(view == nil /*|| [view isKindOfClass:[CKStyleView class]]*/ )
		return NO;
    
	NSMutableDictionary* myViewStyle = style;
	if(!appliedStack || [appliedStack containsObject:view] == NO){
		if(myViewStyle){
			if([myViewStyle isEmpty] == NO){
				UIView* backgroundView = view;
                CKHighlightView* highlightView = nil;
                CKShadowView* shadowView = nil;
                CKShadeView* shadeView = nil;
				BOOL opaque = YES;
				
				CKStyleViewCornerType roundedCornerType = CKStyleViewCornerTypeNone;
				CKStyleViewBorderLocation viewBorderType = CKStyleViewBorderLocationNone;
				CKStyleViewSeparatorLocation viewSeparatorType = CKStyleViewSeparatorLocationNone;
                
                //Problem here is that we apply the view's style to the gradient view
                //but if a lyout is specified for the view, it will be applied to the gradient view too !
                //we ensure we do not have layout information when applying the view's style to the gradient view :
                
                NSMutableDictionary* gradientViewStyle = [NSMutableDictionary dictionaryWithDictionary:myViewStyle];
                [gradientViewStyle removeObjectForKey:@"layoutBoxes"];
                
                if([UIView needHighlightView:myViewStyle forView:view]){
                    highlightView = [[[CKHighlightView alloc]init]autorelease];
                    highlightView.frame = view.bounds;
                    highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    
                    [highlightView setAppliedStyle:myViewStyle];
                    
                    [NSObject applyStyleByIntrospection:gradientViewStyle toObject:highlightView appliedStack:appliedStack delegate:(id)delegate];
                    
                    
                    if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
                        highlightView.roundedCornerSize = [myViewStyle cornerSize];
                    }
                    
                    highlightView.backgroundColor = [UIColor clearColor];
                    
                    [view addSubview:highlightView];
                }
                
                if([UIView needShadowView:myViewStyle forView:view]){
                    shadowView = [[[CKShadowView alloc]init]autorelease];
                    shadowView.frame = view.bounds;
                    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    
                    [shadowView setAppliedStyle:myViewStyle];
                    
                    [NSObject applyStyleByIntrospection:gradientViewStyle toObject:shadowView appliedStack:appliedStack delegate:(id)delegate];
                    
                    
                    if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
                        shadowView.roundedCornerSize = [myViewStyle cornerSize];
                    }
                    
                    shadowView.backgroundColor = [UIColor clearColor];
                    
                    [view addSubview:shadowView];
                }
                
                if([UIView needShadeView:myViewStyle forView:view]){
                    shadeView = [[[CKShadeView alloc]init]autorelease];
                    shadeView.frame = view.bounds;
                    shadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    
                    [shadeView setAppliedStyle:myViewStyle];
                    
                    [NSObject applyStyleByIntrospection:gradientViewStyle toObject:shadeView appliedStack:appliedStack delegate:(id)delegate];
                    
                    
                    if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
                        shadeView.roundedCornerSize = [myViewStyle cornerSize];
                    }
                    
                    [view addSubview:shadeView];
                }
				
				if([UIView needStyleView:myViewStyle forView:view]){
					CKStyleView* gradientView = [UIView styleView:view];
                    [gradientView setAppliedStyle:myViewStyle];
                    
					if(gradientView == nil){
						gradientView = [[[CKStyleView alloc]init]autorelease];
						gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
						view.backgroundColor = [UIColor clearColor];
                        
                        [gradientView setAppliedStyle:myViewStyle];
						[view insertSubview:gradientView atIndex:0];
					}
                    
                    [NSObject applyStyleByIntrospection:gradientViewStyle toObject:gradientView appliedStack:appliedStack delegate:(id)delegate];
		
					backgroundView = gradientView;
				}
				
				//backgroundView.opaque = YES;
                
                //Apply corners
                {
                    CKViewCornerStyle cornerStyle = CKViewCornerStyleTableViewCell;
                    if([myViewStyle containsObjectForKey:CKStyleCornerStyle]){
                        cornerStyle = [myViewStyle cornerStyle];
                    }
                    
                    if((cornerStyle == CKViewCornerStyleTableViewCell) && delegate && [delegate respondsToSelector:@selector(view:cornerStyleWithStyle:)]){
                        roundedCornerType = [delegate view:backgroundView cornerStyleWithStyle:myViewStyle];
                    }
                    else{
                        switch(cornerStyle){
                            case CKViewCornerStyleRounded:{
                                roundedCornerType = CKStyleViewCornerTypeAll;
                                break;
                            }
                            case CKViewCornerStyleRoundedTop:{
                                roundedCornerType = CKStyleViewCornerTypeTop;
                                break;
                            }
                            case CKViewCornerStyleRoundedBottom:{
                                roundedCornerType = CKStyleViewCornerTypeBottom;
                                break;
                            }
                        }
                    }
                    highlightView.corners = roundedCornerType;
                    shadowView.corners = roundedCornerType;
                    shadeView.corners = roundedCornerType;
                }
                
                
                //Apply BorderStyle
                {
                    CKViewBorderStyle borderStyle = CKViewBorderStyleTableViewCell;
                    if([myViewStyle containsObjectForKey:CKStyleBorderStyle]){
                        borderStyle = [myViewStyle borderStyle];
                    }
                    
                    if((borderStyle & CKViewBorderStyleTableViewCell) && delegate && [delegate respondsToSelector:@selector(view:borderStyleWithStyle:)]){
                        viewBorderType = [delegate view:backgroundView borderStyleWithStyle:myViewStyle];
                    }
                    else{
                        viewBorderType = CKStyleViewBorderLocationNone;
                        if(borderStyle & CKViewBorderStyleTop){
                            viewBorderType |= CKStyleViewBorderLocationTop;
                        }
                        if(borderStyle & CKViewBorderStyleLeft){
                            viewBorderType |= CKStyleViewBorderLocationLeft;
                        }
                        if(borderStyle & CKViewBorderStyleRight){
                            viewBorderType |= CKStyleViewBorderLocationRight;
                        }
                        if(borderStyle & CKViewBorderStyleBottom){
                            viewBorderType |= CKStyleViewBorderLocationBottom;
                        }
                    }
                    shadowView.borderLocation = viewBorderType;
                    
                }
                
				
				if([backgroundView isKindOfClass:[CKStyleView class]]){
                    CKStyleView* gradientView = (CKStyleView*)backgroundView;
                    gradientView.corners = roundedCornerType;
					
					//Apply Background Image
					if([myViewStyle containsObjectForKey:CKStyleBackgroundImage]){
						gradientView.image = [myViewStyle backgroundImage];
						//opaque = NO;
					}
                    
					if([myViewStyle containsObjectForKey:CKStyleContentMode]){
						gradientView.contentMode = [myViewStyle contentMode];
					}
                    
					if([myViewStyle containsObjectForKey:CKStyleClipsToBounds]){
						gradientView.clipsToBounds = [myViewStyle clipsToBounds];
					}
					
					if([myViewStyle containsObjectForKey:CKStyleBackgroundImageContentMode]){
						gradientView.imageContentMode = [myViewStyle backgroundImageContentMode];
					}
					
					//Apply Gradient
					if([myViewStyle containsObjectForKey:CKStyleBackgroundGradientColors]){
						NSArray* colors = [myViewStyle backgroundGradientColors];
						for(UIColor* color in colors){
							if(CGColorGetAlpha([color CGColor]) < 1){
								opaque = NO;
								break;
							}
						}
						gradientView.gradientColors = colors;
					}
					if([myViewStyle containsObjectForKey:CKStyleBackgroundGradientLocations]){
						gradientView.gradientColorLocations = [myViewStyle backgroundGradientLocations];
					}
					
					
					//Apply BorderStyle
					{
						gradientView.borderLocation = viewBorderType;
                        
                        if([myViewStyle containsObjectForKey:CKStyleBorderWidth]){
                            gradientView.borderWidth = [myViewStyle borderWidth];
                        }
					}
                    
                    //Apply SeparatorStyle
					{
                        //SeparatorColor
                        UIColor* separatorColor = nil;
                        if([myViewStyle containsObjectForKey:CKStyleSeparatorColor]){
							separatorColor = [myViewStyle separatorColor];
						}else if(delegate && [delegate respondsToSelector:@selector(separatorColorForView:withStyle:)]){
                            separatorColor = [delegate separatorColorForView:gradientView withStyle:myViewStyle];
                        }
						gradientView.separatorColor = separatorColor;
                        
                        
                        if([myViewStyle containsObjectForKey:CKStyleSeparatorWidth]){
                            gradientView.separatorWidth = [myViewStyle separatorWidth];
                        }else if(separatorColor){
                            gradientView.separatorWidth = 1;
                        }
                        
						CKViewSeparatorStyle separatorStyle = CKViewSeparatorStyleTableViewCell;
						if([myViewStyle containsObjectForKey:CKStyleSeparatorStyle]){
							separatorStyle = [myViewStyle separatorStyle];
						}
						
						if(separatorStyle == CKViewSeparatorStyleTableViewCell && delegate && [delegate respondsToSelector:@selector(view:separatorStyleWithStyle:)]){
							viewSeparatorType = [delegate view:gradientView separatorStyleWithStyle:myViewStyle];
						}
						else{
							switch(separatorStyle){
                                case CKViewSeparatorStyleTop:    viewSeparatorType = CKStyleViewSeparatorLocationTop; break;
                                case CKViewSeparatorStyleBottom: viewSeparatorType = CKStyleViewSeparatorLocationBottom; break;
                                case CKViewSeparatorStyleLeft:   viewSeparatorType = CKStyleViewSeparatorLocationLeft; break;
                                case CKViewSeparatorStyleRight:  viewSeparatorType = CKStyleViewSeparatorLocationRight; break;
							}
						}
						gradientView.separatorLocation = viewSeparatorType;
					}
					
					if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
						gradientView.roundedCornerSize = [myViewStyle cornerSize];
					}	
					
					if([myViewStyle containsObjectForKey:CKStyleBorderColor]){
						gradientView.borderColor = [myViewStyle borderColor];
					}	
				}
				
				//Apply transparency
				if([myViewStyle containsObjectForKey:CKStyleAlpha]){
					backgroundView.alpha = [myViewStyle alpha];
				}
                
                UIColor* backColor = backgroundView.backgroundColor;
				//Apply color
				BOOL dontTouchBackgroundColor = NO;
				if([myViewStyle containsObjectForKey:CKStyleBackgroundColor] == YES){
					dontTouchBackgroundColor = YES;
                    backColor = [myViewStyle backgroundColor];
				}
				
				if(dontTouchBackgroundColor == NO && (roundedCornerType != CKStyleViewCornerTypeNone)){
                    backColor = [UIColor clearColor];
				}
                
                backgroundView.backgroundColor = backColor;
                CGFloat alpha = CGColorGetAlpha([backColor CGColor]);
                opaque = opaque && (alpha >= 1);
                
                backgroundView.opaque = opaque;
                
				if([backgroundView isKindOfClass:[CKStyleView class]]){
                    backgroundView.frame = view.bounds;
                }
				
				/*BOOL colorOpaque = (opaque == YES && (roundedCornerType == CKStyleViewCornerTypeNone));
				if(dontTouchBackgroundColor == NO){
					//backgroundView.backgroundColor = [UIColor clearColor];
					backgroundView.backgroundColor = [UIColor redColor];
				}*/
			}
            
            
            [view setAppliedStyle:myViewStyle];
		}
        
        if(appliedStack != nil){
            [appliedStack addObject:view];
            //Root to leaf instead of leaf to root like before.
            [view applySubViewsStyle:myViewStyle appliedStack:appliedStack delegate:delegate];
        }
		return YES;
	}
	return NO;
}




- (void)populateViewDictionaryForVisualFormat:(NSMutableDictionary*)dico{
    if([self name]){
        [dico setObject:self forKey:[self name]];
    }
    
    for(UIView* subview in [self subviews]){
        [subview populateViewDictionaryForVisualFormat:dico];
    }
}

@end


static char NSObjectAppliedStyleObjectKey;

@implementation NSObject (CKStyle)
@dynamic appliedStyle;

- (void)setAppliedStyle:(NSMutableDictionary*)s{
        objc_setAssociatedObject(self, 
                                 &NSObjectAppliedStyleObjectKey,
                                 s,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)appliedStyle{
    return objc_getAssociatedObject(self, &NSObjectAppliedStyleObjectKey);
}

- (NSString*)appliedStylePath{
    NSMutableDictionary* style = nil;
    style = [self appliedStyle];

    return [style path];
}

- (NSString*)appliedStyleDescription{
    return cleanString([NSString stringWithFormat:@"Path : %@ \nStyle : {\n%@\n}",[self appliedStylePath],[[self appliedStyle] lightStyleDescriptionWithIndentation:1]]);
}

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
    
}

- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style{
	[[self class] applyStyle:style toObject:self appliedStack:[NSMutableSet set] delegate:nil];
    return style;
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
    [object applySubViewsStyle:style appliedStack:appliedStack delegate:delegate];
    return YES;
}

+ (void)applyStyleByIntrospection:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
    if([style isEmpty])
        return;
    
	/*if(reserverKeyWords == nil){
	}*/
	
    NSMutableSet* reserverKeyWords = [NSMutableSet set];
	[[self class]updateReservedKeyWords:reserverKeyWords];
	
	for(NSString* key in [style allKeys]){
		if([reserverKeyWords containsObject:key] == NO){
			CKClassPropertyDescriptor* descriptor = [object propertyDescriptorForKeyPath:key];
            
            if(descriptor){
                
                CKProperty* property = [CKProperty weakPropertyWithObject:object keyPath:key];
                if(![property isKVCComplient])
                    continue;
                
                //When creating subviews by introspection, ensure style is applied on these views.
                if([descriptor.name isEqualToString: @"subviews"] && [object isKindOfClass:[UIView class]]){
                    //FIXME : We could propbably optimize here by not creating the CKProperty as it registers weakrefs and other stuff ...
                    [style setObjectForKey:key inProperty:property];
                    
                    UIView* view = (UIView*)object;
                    for(UIView* subView in view.subviews){
                        
                        NSMutableDictionary* myViewStyle = [style styleForObject:subView propertyName:nil];
                        [[subView class] applyStyle:myViewStyle toView:subView appliedStack:appliedStack delegate:delegate];
                    }
                }
                else{
                    BOOL isUIView = (descriptor != nil && [NSObject isClass:descriptor.type kindOfClass:[UIView class]] == YES);
                    if(!isUIView){
                        //FIXME : We could propbably optimize here by not creating the CKProperty as it registers weakrefs and other stuff ...
                        [style setObjectForKey:key inProperty:property];
                    }
                    else if(isUIView){
                        if(   ([object isKindOfClass:[UITableViewCell class]] && [descriptor.name isEqualToString:@"selectedBackgroundView"])
                           || ([object isKindOfClass:[UITableView class]] && [descriptor.name isEqualToString:@"backgroundView"])){
                            //DO NOTHING !
                        }
                        else{
                            id theView = [object valueForKeyPath:key];
                            if(!theView){
                                id subViewStyle = [style objectForKey:key];
                                NSString* className = [subViewStyle objectForKey:@"@class"];
                                Class theClass = NSClassFromString(className);
                                if(theClass && [NSObject isClass:theClass kindOfClass:[UIView class]] == YES){
                                    UIView* createdView = [[[theClass alloc]initWithFrame:CGRectMake(0,0,100,100)]autorelease];
                                    [[createdView class] applyStyle:subViewStyle toView:createdView appliedStack:appliedStack delegate:delegate];
                                    [object setValue:createdView forKeyPath:key];
                                }
                            }
                        }
                    }
                }
            }
		}
	}
}

- (void)applySubViewStyle:(NSMutableDictionary*)style
               descriptor:(CKClassPropertyDescriptor*)descriptor
             appliedStack:(NSMutableSet*)appliedStack
                 delegate:(id)delegate{
    
    if(!descriptor)
        return;
    
    CKProperty* property = [CKProperty weakPropertyWithObject:self keyPath:descriptor.name];
    if(![property isKVCComplient])
        return;
    
    //Handle special cases where styles should not be applyed !
    if([[[self class]description]isEqualToString:@"UITableHeaderFooterView"] &&
       [NSObject isClass:descriptor.type kindOfClass:[UITableView class]]){
        return;
    }
    
    //Handle special cases for view property in CKCollectionCellController !
    if([[[self class]description]isEqualToString:@"CKCollectionCellController"] &&
       [descriptor.name isEqualToString:@"view"]){
        return;
    }
    
    UIView* view = nil;
    if(   ([self isKindOfClass:[UITableViewCell class]] && [descriptor.name isEqualToString:@"selectedBackgroundView"])
       || ([self isKindOfClass:[UITableView class]] && [descriptor.name isEqualToString:@"backgroundView"])){
        //We are supposed to get a nil view here ! but UIKit creates a view when getting selectedBackgroundView wich have not the right class if called here.
    }
    else{
        view = [self valueForKey:descriptor.name];
    }
    
    NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:descriptor.name];
    
    if([CKStyleManager logEnabled]){
        if([myViewStyle isEmpty]){
            CKDebugLog(@"did not find style for view %@ in parent %@ with style %@",descriptor.name,self,style);
        }
        else{
            CKDebugLog(@"found style %@ for view %@ in parent %@",myViewStyle,descriptor.name,self);
        }
    }
    
    if([myViewStyle isEmpty])
        return;
    
    if(([view appliedStyle] == nil || [[view appliedStyle]isEmpty])){
        
        //if(![myViewStyle isEmpty]){
        BOOL shouldReplaceView = NO;
        if(delegate && [delegate respondsToSelector:@selector(object:shouldReplaceViewWithDescriptor:withStyle:)]){
            shouldReplaceView = [delegate object:self shouldReplaceViewWithDescriptor:descriptor withStyle:myViewStyle];
        }
        
        if(([UIView needStyleView:myViewStyle forView:view] && view == nil) || (shouldReplaceView && (view == nil || [view isKindOfClass:[CKStyleView class]] == NO)) )
        {
            UIView* referenceView = (view != nil) ? view : (([self isKindOfClass:[UIView class]] == YES) ? (UIView*)self : nil);
            CGRect frame = (referenceView != nil) ? referenceView.bounds : CGRectMake(0,0,100,100);
            view = [[[CKStyleView alloc]initWithFrame:frame]autorelease];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self setValue:view forKey:descriptor.name];
        }
        
        if(view){
            [[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack delegate:delegate];
        }
        //}
    }
    
    [view setNeedsDisplay];
}

//FIXME : something not optimial here as we retrieve myViewStyle which is done also in applyStyle
- (void)applySubViewsStyle:(NSMutableDictionary*)style appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
	if(style == nil)
		return;
    
    
	//if([appliedStack containsObject:self] == NO){
    [[self class] applyStyleByIntrospection:style toObject:self appliedStack:appliedStack delegate:delegate];
	//}
	
	//iterate on view properties to apply style using property names
	NSArray* properties = [self allViewsPropertyDescriptors];
	for(CKClassPropertyDescriptor* descriptor in properties){
        [self applySubViewStyle:style descriptor:descriptor appliedStack:appliedStack delegate:delegate];
	}
	
    
    if(![self isKindOfClass:[UITableView class]] && ![self isKindOfClass:[UIWindow class]]){
        //Style are applyed by cell controllers and header/footer view insertion for tables ...
        
        if([self isKindOfClass:[UIView class]] == YES){
            UIView* selfView = (UIView*)self;
            for(UIView* view in [selfView subviews]){
                if([view isKindOfClass:[CKStyleView class]])
                    continue;
                
                if(([view appliedStyle] == nil || [[view appliedStyle]isEmpty]) && ![appliedStack containsObject:view]){
                    NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:nil];
                    [[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack delegate:delegate];
                }else{
                    [appliedStack addObject:view];
                }
            }
        }
    }
	
    [self setAppliedStyle:style];
	
	[appliedStack addObject:self];
}


@end
