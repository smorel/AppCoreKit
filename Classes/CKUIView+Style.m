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


NSMutableSet* reserverKeyWords = nil;

NSString* CKStyleBackgroundColor = @"backgroundColor";
NSString* CKStyleBackgroundGradientColors = @"backgroundGradientColors";
NSString* CKStyleBackgroundGradientLocations = @"backgroundGradientLocations";
NSString* CKStyleBackgroundImage = @"backgroundImage";
NSString* CKStyleCornerStyle = @"cornerStyle";
NSString* CKStyleCornerSize = @"cornerSize";
NSString* CKStyleAlpha = @"alpha";
NSString* CKStyleBorderColor = @"borderColor";
NSString* CKStyleBorderWidth = @"borderWidth";
NSString* CKStyleBorderStyle = @"borderStyle";
NSString* CKStyleBackgroundImageContentMode = @"backgroundImageContentMode";


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
                                                                     CKViewCornerStyleDefault, 
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
                                                                     CKViewBorderStyleDefault,
																	 CKViewBorderStyleAll,
																	 CKViewBorderStyleNone)];
}

@end

@implementation UIView (CKStyle)

+ (CKGradientView*)gradientView:(UIView*)view{
	if([view isKindOfClass:[CKGradientView class]])
		return (CKGradientView*)view;
	
	for(UIView* subView in [view subviews]){
		if([subView isKindOfClass:[CKGradientView class]])
			return (CKGradientView*)subView;
	}
	return nil;
}

+ (BOOL)needSubView:(NSMutableDictionary*)style forView:(UIView*)view{
	if(style == nil || [style isEmpty] == YES)
		return NO;
	
	if([style containsObjectForKey:CKStyleBackgroundGradientColors]
	   || [style containsObjectForKey:CKStyleCornerStyle]
	   || [style containsObjectForKey:CKStyleBackgroundImage]
	   || [style containsObjectForKey:CKStyleBorderColor]){
		return YES;
	}
	return NO;
}

- (void)applyStyle:(NSMutableDictionary*)style{
	[self applyStyle:style propertyName:nil];
}

- (void)applyStyle:(NSMutableDictionary*)style propertyName:(NSString*)propertyName{
	NSMutableDictionary* myViewStyle = [style styleForObject:self propertyName:propertyName];
	[[self class] applyStyle:myViewStyle toView:self appliedStack:[NSMutableSet set] delegate:nil];
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:propertyName];
	return [[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack  delegate:nil];
}

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleBackgroundColor,CKStyleBackgroundGradientColors,CKStyleBackgroundGradientLocations,CKStyleBackgroundImageContentMode,
								   CKStyleBackgroundImage,CKStyleCornerStyle,CKStyleCornerSize,CKStyleAlpha,CKStyleBorderColor,CKStyleBorderWidth,CKStyleBorderStyle,@"@class",nil]];
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack
                   delegate:(id)delegate {
	if(view == nil)
		return NO;
    
	NSMutableDictionary* myViewStyle = style;
	if([appliedStack containsObject:view] == NO){
		if(myViewStyle){
			if([myViewStyle isEmpty] == NO){
				UIView* backgroundView = view;
				BOOL opaque = YES;
				
				CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
				CKGradientViewBorderType viewBorderType = CKGradientViewBorderTypeNone;
				
				if([UIView needSubView:myViewStyle forView:view]){
					CKGradientView* gradientView = [UIView gradientView:view];
					if(gradientView == nil){
						gradientView = [[[CKGradientView alloc]initWithFrame:view.bounds]autorelease];
						gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
						view.backgroundColor = [UIColor clearColor];
						[view insertSubview:gradientView atIndex:0];
					}
                    
                    [NSObject applyStyleByIntrospection:myViewStyle toObject:gradientView appliedStack:appliedStack delegate:(id)delegate];
		
					backgroundView = gradientView;
				}
				
				//backgroundView.opaque = YES;
				
				if([backgroundView isKindOfClass:[CKGradientView class]]){
					CKGradientView* gradientView = (CKGradientView*)backgroundView;
					
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
						CKViewCornerStyle cornerStyle = CKViewCornerStyleDefault;
						if([myViewStyle containsObjectForKey:CKStyleCornerStyle]){
							cornerStyle = [myViewStyle cornerStyle];
						}
						
						if(cornerStyle == CKViewCornerStyleDefault && delegate && [delegate respondsToSelector:@selector(view:cornerStyleWithStyle:)]){
							roundedCornerType = [delegate view:gradientView cornerStyleWithStyle:myViewStyle];
						}
						else{
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
						CKViewBorderStyle borderStyle = CKViewBorderStyleDefault;
						if([myViewStyle containsObjectForKey:CKStyleBorderStyle]){
							borderStyle = [myViewStyle borderStyle];
						}
						
						if(borderStyle == CKViewCornerStyleDefault && delegate && [delegate respondsToSelector:@selector(view:borderStyleWithStyle:)]){
							viewBorderType = [delegate view:gradientView borderStyleWithStyle:myViewStyle];
						}
						else{
							switch(borderStyle){
								case CKViewBorderStyleAll:{
									viewBorderType = CKGradientViewBorderTypeAll;
									break;
								}
								case CKViewBorderStyleNone:{
									viewBorderType = CKGradientViewBorderTypeNone;
									break;
								}
							}
						}
						gradientView.borderStyle = viewBorderType;
					}
					
					if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
						gradientView.roundedCornerSize = [myViewStyle cornerSize];
					}	
					
					if([myViewStyle containsObjectForKey:CKStyleBorderColor]){
						gradientView.borderColor = [myViewStyle borderColor];
					}	
					
					if([myViewStyle containsObjectForKey:CKStyleBorderWidth]){
						gradientView.borderWidth = [myViewStyle borderWidth];
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
        
        [appliedStack addObject:view];
		//Root to leaf instead of leaf to root like before.
		[view applySubViewsStyle:myViewStyle appliedStack:appliedStack delegate:delegate];
		return YES;
	}
	return NO;
}

@end


@implementation NSObject (CKStyle)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
    
}

+ (void)applyStyleByIntrospection:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
    if([style isEmpty])
        return;
    
	if(reserverKeyWords == nil){
		reserverKeyWords = [[NSMutableSet set]retain];
	}
	
	[[self class]updateReservedKeyWords:reserverKeyWords];
	
	for(NSString* key in [style allKeys]){
		if([reserverKeyWords containsObject:key] == NO){
			CKClassPropertyDescriptor* descriptor = [object propertyDescriptorForKeyPath:key];
            if(descriptor){
                BOOL isUIView = (descriptor != nil && [NSObject isKindOf:descriptor.type parentType:[UIView class]] == YES);
                if(!isUIView){
                    [style setObjectForKey:key inProperty:[CKObjectProperty propertyWithObject:object keyPath:key]];
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
                            if(theClass && [NSObject isKindOf:theClass parentType:[UIView class]] == YES){
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
                NSLog(@"did not find style for view %@ in parent %@ with style %@",descriptor.name,self,style);
            }
            else{
                NSLog(@"found style %@ for view %@ in parent %@",myViewStyle,descriptor.name,self);
            }
        }
        
		//if(![myViewStyle isEmpty]){
			BOOL shouldReplaceView = NO;
			if(delegate && [delegate respondsToSelector:@selector(object:shouldReplaceViewWithDescriptor:withStyle:)]){
				shouldReplaceView = [delegate object:self shouldReplaceViewWithDescriptor:descriptor withStyle:myViewStyle];
			}
			
			if(([UIView needSubView:myViewStyle forView:view] && view == nil) || (shouldReplaceView && (view == nil || [view isKindOfClass:[CKGradientView class]] == NO)) )
            {
                UIView* referenceView = (view != nil) ? view : (([self isKindOfClass:[UIView class]] == YES) ? (UIView*)self : nil);
                CGRect frame = (referenceView != nil) ? referenceView.bounds : CGRectMake(0,0,100,100);
				view = [[[CKGradientView alloc]initWithFrame:frame]autorelease];
				view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				[self setValue:view forKey:descriptor.name];
			}
			
			if(view){
				[[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack delegate:delegate];
			}
		//}
	}
	
	if([self isKindOfClass:[UIView class]] == YES){
		UIView* selfView = (UIView*)self;
		for(UIView* view in [selfView subviews]){
            if(![appliedStack containsObject:view]){
                NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:nil];
                [[view class] applyStyle:myViewStyle toView:view appliedStack:appliedStack delegate:delegate];
            }
		}
	}
	
	
	//if([appliedStack containsObject:self] == NO){
		[[self class] applyStyleByIntrospection:style toObject:self appliedStack:appliedStack delegate:delegate];
	//}
	[appliedStack addObject:self];
}


@end
