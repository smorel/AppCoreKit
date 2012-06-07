//
//  CKUIView+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"

#import "CKTableViewCellController+Style.h"
#import "CKUILabel+Style.h"
#import "CKLocalization.h"

#import "CKTextView.h"
#import "CKDebug.h"
#import <objc/runtime.h>


//NSMutableSet* reserverKeyWords = nil;

NSString* CKStyleBackgroundColor = @"backgroundColor";
NSString* CKStyleBackgroundGradientColors = @"backgroundGradientColors";
NSString* CKStyleBackgroundGradientLocations = @"backgroundGradientLocations";
NSString* CKStyleBackgroundImage = @"backgroundImage";
NSString* CKStyleCornerStyle = @"cornerStyle";
NSString* CKStyleCornerSize = @"cornerSize";
NSString* CKStyleAlpha = @"alpha";
NSString* CKStyleBackgroundImageContentMode = @"backgroundImageContentMode";


NSString* CKStyleBorderColor = @"borderColor";
NSString* CKStyleBorderWidth = @"borderWidth";
NSString* CKStyleBorderStyle = @"borderStyle";

NSString* CKStyleSeparatorColor = @"separatorColor";
NSString* CKStyleSeparatorWidth = @"separatorWidth";
NSString* CKStyleSeparatorStyle = @"separatorStyle";


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
									 withEnumDescriptor:CKEnumDefinition(@"CKViewBorderStyle",
                                                                     CKViewBorderStyleTableViewCell,
																	 CKViewBorderStyleAll,
																	 CKViewBorderStyleNone)];
}

- (UIColor*)separatorColor{
	return [self colorForKey:CKStyleSeparatorColor];
}

- (CGFloat)separatorWidth{
	return [self cgFloatForKey:CKStyleSeparatorWidth];
}

- (CKViewSeparatorStyle)separatorStyle{
	return (CKViewSeparatorStyle)[self enumValueForKey:CKStyleSeparatorStyle 
                                 withEnumDescriptor:CKEnumDefinition(@"CKViewSeparatorStyle",
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

@end

@implementation UIView (CKStyle)

+ (CKStyleView*)gradientView:(UIView*)view{
	if([view isKindOfClass:[CKStyleView class]])
		return (CKStyleView*)view;
	
	for(UIView* subView in [view subviews]){
		if([subView isKindOfClass:[CKStyleView class]])
			return (CKStyleView*)subView;
	}
	return nil;
}

+ (BOOL)needSubView:(NSMutableDictionary*)style forView:(UIView*)view{
	if(style == nil || [style isEmpty] == YES)
		return NO;
	
    //TODO : check if colors in style are clear color ... or image is nil ...
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
	if(view == nil)
		return NO;
    
	NSMutableDictionary* myViewStyle = style;
	if(!appliedStack || [appliedStack containsObject:view] == NO){
		if(myViewStyle){
			if([myViewStyle isEmpty] == NO){
				UIView* backgroundView = view;
				BOOL opaque = YES;
				
				CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
				CKStyleViewBorderLocation viewBorderType = CKStyleViewBorderLocationNone;
				CKStyleViewSeparatorLocation viewSeparatorType = CKStyleViewSeparatorLocationNone;
				
				if([UIView needSubView:myViewStyle forView:view]){
					CKStyleView* gradientView = [UIView gradientView:view];
                    [gradientView setAppliedStyle:myViewStyle];
                    
					if(gradientView == nil){
						gradientView = [[[CKStyleView alloc]initWithFrame:view.bounds]autorelease];
						gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
						view.backgroundColor = [UIColor clearColor];
                        
                        [gradientView setAppliedStyle:myViewStyle];
						[view insertSubview:gradientView atIndex:0];
					}
                    
                    [NSObject applyStyleByIntrospection:myViewStyle toObject:gradientView appliedStack:appliedStack delegate:(id)delegate];
		
					backgroundView = gradientView;
				}
				
				//backgroundView.opaque = YES;
				
				if([backgroundView isKindOfClass:[CKStyleView class]]){
					CKStyleView* gradientView = (CKStyleView*)backgroundView;
					
					//Apply Background Image
					if([myViewStyle containsObjectForKey:CKStyleBackgroundImage]){
						gradientView.image = [myViewStyle backgroundImage];
						//opaque = NO;
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
					
					//Apply corners
					{
						if(delegate && [delegate respondsToSelector:@selector(view:cornerStyleWithStyle:)]){
							roundedCornerType = [delegate view:gradientView cornerStyleWithStyle:myViewStyle];
						}
						else{
                            CKViewCornerStyle cornerStyle = CKViewCornerStyleTableViewCell;
                            if([myViewStyle containsObjectForKey:CKStyleCornerStyle]){
                                cornerStyle = [myViewStyle cornerStyle];
                            }
							switch(cornerStyle){
								case CKViewCornerStyleRounded:{
									roundedCornerType = CKRoundedCornerViewTypeAll;
									break;
								}
								case CKViewCornerStyleRoundedTop:{
									roundedCornerType = CKRoundedCornerViewTypeTop;
									break;
								}
								case CKViewCornerStyleRoundedBottom:{
									roundedCornerType = CKRoundedCornerViewTypeBottom;
									break;
								}
							}
						}
						gradientView.corners = roundedCornerType;
					}
					
					//Apply BorderStyle
					{
						CKViewBorderStyle borderStyle = CKViewBorderStyleTableViewCell;
						if([myViewStyle containsObjectForKey:CKStyleBorderStyle]){
							borderStyle = [myViewStyle borderStyle];
						}
						
						if(borderStyle == CKViewBorderStyleTableViewCell && delegate && [delegate respondsToSelector:@selector(view:borderStyleWithStyle:)]){
							viewBorderType = [delegate view:gradientView borderStyleWithStyle:myViewStyle];
						}
						else{
							switch(borderStyle){
								case CKViewBorderStyleAll:{
									viewBorderType = CKStyleViewBorderLocationAll;
									break;
								}
								case CKViewBorderStyleNone:{
									viewBorderType = CKStyleViewBorderLocationNone;
									break;
								}
							}
						}
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
					
					
					[gradientView setNeedsDisplay];
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
				
				if(dontTouchBackgroundColor == NO && (roundedCornerType != CKRoundedCornerViewTypeNone)){
                    backColor = [UIColor clearColor];
				}
                
                backgroundView.backgroundColor = backColor;
                CGFloat alpha = CGColorGetAlpha([backColor CGColor]);
                opaque = opaque && (alpha >= 1);
                
                backgroundView.opaque = opaque;
				
				/*BOOL colorOpaque = (opaque == YES && (roundedCornerType == CKRoundedCornerViewTypeNone));
				if(dontTouchBackgroundColor == NO){
					//backgroundView.backgroundColor = [UIColor clearColor];
					backgroundView.backgroundColor = [UIColor redColor];
				}*/
			}
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

@end


static char NSObjectAppliedStyleObjectKey;

@implementation NSObject (CKStyle)
@dynamic appliedStyle;

- (void)setAppliedStyle:(NSMutableDictionary*)appliedStyle{
#if !TARGET_IPHONE_SIMULATOR
    objc_setAssociatedObject(self, 
                             &NSObjectAppliedStyleObjectKey,
                             appliedStyle,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
}

- (NSMutableDictionary*)appliedStyle{
    return objc_getAssociatedObject(self, &NSObjectAppliedStyleObjectKey);
}

- (NSString*)appliedStylePath{
    NSMutableDictionary* style = [self appliedStyle];
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
                BOOL isUIView = (descriptor != nil && [NSObject isClass:descriptor.type kindOfClass:[UIView class]] == YES);
                if(!isUIView){
                    //FIXME : We could propbably optimize here by not creating the CKProperty as it registers weakrefs and other stuff ...
                    [style setObjectForKey:key inProperty:[CKProperty propertyWithObject:object keyPath:key]];
                }
                else if(isUIView){
                    if([object isKindOfClass:[UITableViewCell class]] && [descriptor.name isEqualToString:@"selectedBackgroundView"]){
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

//FIXME : something not optimial here as we retrieve myViewStyle which is done also in applyStyle
- (void)applySubViewsStyle:(NSMutableDictionary*)style appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
	if(style == nil)
		return;
	
	//iterate on view properties to apply style using property names
	NSArray* properties = [self allViewsPropertyDescriptors];
	for(CKClassPropertyDescriptor* descriptor in properties){
        
        //Handle special cases where styles should not be applyed !
        if([[[self class]description]isEqualToString:@"UITableHeaderFooterView"] &&
           [NSObject isClass:descriptor.type kindOfClass:[UITableView class]]){
            continue;
        }
        
        
		UIView* view = nil;
        if([self isKindOfClass:[UITableViewCell class]] && [descriptor.name isEqualToString:@"selectedBackgroundView"]){
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
        
		//if(![myViewStyle isEmpty]){
			BOOL shouldReplaceView = NO;
			if(delegate && [delegate respondsToSelector:@selector(object:shouldReplaceViewWithDescriptor:withStyle:)]){
				shouldReplaceView = [delegate object:self shouldReplaceViewWithDescriptor:descriptor withStyle:myViewStyle];
			}
			
			if(([UIView needSubView:myViewStyle forView:view] && view == nil) || (shouldReplaceView && (view == nil || [view isKindOfClass:[CKStyleView class]] == NO)) )
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
	
    
    if(![self isKindOfClass:[UITableView class]]){
        //Style are applyed by cell controllers and header/footer view insertion for tables ...
        
        if([self isKindOfClass:[UIView class]] == YES){
            UIView* selfView = (UIView*)self;
            for(UIView* view in [selfView subviews]){
                if(![appliedStack containsObject:view]){
                    NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:nil];
                    [[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack delegate:delegate];
                }
            }
        }
    }
	
    [self setAppliedStyle:style];
	
	//if([appliedStack containsObject:self] == NO){
		[[self class] applyStyleByIntrospection:style toObject:self appliedStack:appliedStack delegate:delegate];
	//}
	[appliedStack addObject:self];
}


@end
