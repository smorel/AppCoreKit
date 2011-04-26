//
//  CKUIView+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"
#import "CKStyles.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"

#import "CKTableViewCellController+Style.h"
#import "CKUILabel+Style.h"
#import "CKUIImageView+Style.h"
#import "CKGradientView.h"
#import "CKUITableView+Style.h"

NSString* CKStyleColor = @"color";
NSString* CKStyleGradientColors = @"gradientColors";
NSString* CKStyleGradientLocations = @"gradientLocations";
NSString* CKStyleImage = @"image";
NSString* CKStyleCornerStyle = @"cornerStyle";
NSString* CKStyleCornerSize = @"cornerSize";
NSString* CKStyleAlpha = @"alpha";

@implementation NSMutableDictionary (CKViewStyle)

- (UIColor*)color{
	return [self colorForKey:CKStyleColor];
}

- (NSArray*)gradientColors{
	return [self colorArrayForKey:CKStyleGradientColors];
}

- (NSArray*)gradientLocations{
	return [self cgFloatArrayForKey:CKStyleGradientLocations];
}

- (UIImage*)image{
	return [self imageForKey:CKStyleImage];
} 

- (CKViewCornerStyle)cornerStyle{
	return (CKViewCornerStyle)[self enumValueForKey:CKStyleCornerStyle 
									 withDictionary:CKEnumDictionary(CKViewCornerStyleDefault, CKViewCornerStyleRounded, CKViewCornerStylePlain)];
}

- (CGSize)cornerSize{
	return [self cgSizeForKey:CKStyleCornerSize];
}

- (CGFloat)alpha{
	return [self cgFloatForKey:CKStyleAlpha];
}

@end

@implementation UIView (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style{
	[self applyStyle:style propertyName:@""];
}

- (void)applyStyle:(NSMutableDictionary*)style propertyName:(NSString*)propertyName{
	[[self class] applyStyle:style toView:self propertyName:propertyName appliedStack:[NSMutableSet set]];
}

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
	BOOL isTableViewCell = [[view superview]isKindOfClass:[UITableViewCell class]];
	
	if(isTableViewCell
	   || [style containsObjectForKey:CKStyleGradientColors]
	   || [style containsObjectForKey:CKStyleCornerStyle]
	   || [style containsObjectForKey:CKStyleImage]){
		return YES;
	}
	return NO;
}

+ (BOOL)needSubView:(NSMutableDictionary*)style forView:(UIView*)view propertyName:(NSString*)propertyName{
	NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:propertyName];
	if([myViewStyle containsObjectForKey:CKStyleGradientColors]
	   || [myViewStyle containsObjectForKey:CKStyleCornerStyle]
	   || [myViewStyle containsObjectForKey:CKStyleImage]){
		return YES;
	}
	return NO;
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack
                   cornerModifierTarget:(id)target cornerModifierAction:(SEL)action {
	if(view == nil)
		return NO;
	
	NSMutableDictionary* myViewStyle = [style styleForObject:view propertyName:propertyName];
	if([appliedStack containsObject:view] == NO){
		//Apply before adding background subView
		[view applySubViewsStyle:myViewStyle appliedStack:appliedStack];
		
		if(myViewStyle){
			if([myViewStyle count] > 0){
				UIView* backgroundView = view;
				BOOL opaque = YES;
				if([UIView needSubView:myViewStyle forView:view]){
					CKGradientView* gradientView = [UIView gradientView:view];
					if(gradientView == nil){
						gradientView = [[[CKGradientView alloc]initWithFrame:view.bounds]autorelease];
						gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
						view.backgroundColor = [UIColor clearColor];
						[view insertSubview:gradientView atIndex:0];
					}
					
					if([myViewStyle containsObjectForKey:CKStyleImage]){
						gradientView.image = [myViewStyle image];
					}
					
					if([myViewStyle containsObjectForKey:CKStyleGradientColors]){
						NSArray* colors = [myViewStyle gradientColors];
						for(UIColor* color in colors){
							if(CGColorGetAlpha([color CGColor]) < 1){
								opaque = NO;
								break;
							}
						}
						gradientView.gradientColors = colors;
					}
					if([myViewStyle containsObjectForKey:CKStyleGradientLocations]){
						gradientView.gradientColorLocations = [myViewStyle gradientLocations];
					}
					
					//Apply corners
					CKViewCornerStyle cornerStyle = CKViewCornerStyleDefault;
					if([myViewStyle containsObjectForKey:CKStyleCornerStyle]){
						cornerStyle = [myViewStyle cornerStyle];
					}
					
					CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
					if(target && action){
						roundedCornerType = [[target performSelector:action withObject:myViewStyle] intValue];
					}
					else{
						switch(cornerStyle){
							case CKViewCornerStyleRounded:{
								roundedCornerType = CKRoundedCornerViewTypeAll;
								break;
							}
						}
					}
					
					gradientView.corners = roundedCornerType;
					gradientView.backgroundColor = (opaque && roundedCornerType == CKRoundedCornerViewTypeNone) ? [UIColor blackColor] : [UIColor clearColor];
					
					if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
						gradientView.roundedCornerSize = [myViewStyle cornerSize];
					}
					
					
					backgroundView = gradientView;
				}
				
				//Apply transparency
				if([myViewStyle containsObjectForKey:CKStyleAlpha]){
					backgroundView.alpha = [myViewStyle alpha];
				}
				
				//Apply color
				if([myViewStyle containsObjectForKey:CKStyleColor] == YES
				   && [myViewStyle containsObjectForKey:CKStyleGradientColors] == NO){
					if([backgroundView isKindOfClass:[CKGradientView class]]){
						CKGradientView* gradientView = (CKGradientView*)backgroundView;
						UIColor* color = [myViewStyle color];
						gradientView.gradientColors = [NSArray arrayWithObjects:color,color,nil];
						gradientView.gradientColorLocations = [NSArray arrayWithObjects:
															   [NSNumber numberWithInt:0], 
															   [NSNumber numberWithInt:1], 
															   nil];	
						opaque = opaque && (CGColorGetAlpha([color CGColor]) >= 1);				
					}
					else{
						backgroundView.backgroundColor = [myViewStyle color];
						opaque = opaque && (CGColorGetAlpha([backgroundView.backgroundColor CGColor]) >= 1);
					}
				}
				backgroundView.opaque = opaque && (backgroundView.alpha >= 1) ? YES : NO;
			}
			
			[appliedStack addObject:view];
		}
		return YES;
	}
	return NO;
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	return [[view class] applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack  cornerModifierTarget:nil cornerModifierAction:nil];
}

- (void)applySubViewsStyle:(NSMutableDictionary*)style appliedStack:(NSMutableSet*)appliedStack{
	for(UIView* view in [self subviews]){
		[[view class] applyStyle:style toView:view propertyName:@"" appliedStack:appliedStack];
	}
}

/*
 NSDictionary* backgroundStyle = [myViewStyle backgroundStyle];
 if(backgroundStyle == nil){backgroundStyle = [NSDictionary dictionary];}
 NSDictionary* selectedBackgroundStyle = [myViewStyle selectedBackgroundStyle];
 if(selectedBackgroundStyle == nil){selectedBackgroundStyle = [NSDictionary dictionary];}
 
 //Applying style on Background view
 {
 //create view
 UIView* view = self.backgroundView;
 CKGradientView* gradientView = nil;
 if([view isKindOfClass:[CKGradientView class]] == NO){
 gradientView = [[[CKGradientView alloc]initWithFrame:self.bounds]autorelease];
 gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 self.backgroundView = gradientView;
 }
 else{
 gradientView = (CKGradientView*)view;
 }
 //apply colors
 if([backgroundStyle containsObjectForKey:CKStyleGradientColors]){
 gradientView.gradientColors = [backgroundStyle gradientColors];
 gradientView.gradientColorLocations = [NSArray arrayWithObjects:
 [NSNumber numberWithInt:0], 
 [NSNumber numberWithFloat:(1 / self.bounds.size.height)], 
 [NSNumber numberWithFloat:(1 - (1 / self.bounds.size.height))], 
 [NSNumber numberWithInt:1], 
 nil];
 }
 else{
 UIColor* color = [backgroundStyle color];
 gradientView.gradientColors = [NSArray arrayWithObjects:color,color,nil];
 gradientView.gradientColorLocations = [NSArray arrayWithObjects:
 [NSNumber numberWithInt:0], 
 [NSNumber numberWithInt:1], 
 nil];
 }
 
 gradientView.alpha = [backgroundStyle alpha];
 gradientView.backgroundColor = [self parentControllerView:parentController].backgroundColor;
 
 CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
 switch([backgroundStyle cornerStyle]){
 case CKViewCornerStyleRounded:{
 roundedCornerType = CKRoundedCornerViewTypeAll;
 break;
 }
 case CKViewCornerStyleDefault:{
 UIView* parentView = [self parentControllerView:parentController];
 if([parentView isKindOfClass:[UITableView class]]){
 UITableView* tableView = (UITableView*)parentView;
 if(tableView.style == UITableViewStyleGrouped){
 NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
 if(indexPath.row == 0 && numberOfRows > 1){
 roundedCornerType = CKRoundedCornerViewTypeTop;
 }
 else if(indexPath.row == 0){
 roundedCornerType = CKRoundedCornerViewTypeAll;
 }
 else if(indexPath.row == numberOfRows-1){
 roundedCornerType = CKRoundedCornerViewTypeBottom;
 }
 }
 }
 break;
 }
 }
 
 gradientView.corners = roundedCornerType;
 gradientView.roundedCornerSize = [backgroundStyle cornerSize];
 }
 
 [appliedStack addObject:self.backgroundView];
 [self.backgroundView applySubViewsStyle:backgroundStyle appliedStack:appliedStack];
 
 //Applying style on Selected view
 {
 //create view
 UIView* view = self.selectedBackgroundView;
 CKGradientView* gradientView = nil;
 if([view isKindOfClass:[CKGradientView class]] == NO){
 gradientView = [[[CKGradientView alloc]initWithFrame:self.bounds]autorelease];
 gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 self.selectedBackgroundView = gradientView;
 }
 else{
 gradientView = (CKGradientView*)view;
 }
 
 //apply colors
 if([selectedBackgroundStyle containsObjectForKey:CKStyleGradientColors]){
 gradientView.gradientColors = [selectedBackgroundStyle gradientColors];
 gradientView.gradientColorLocations = [NSArray arrayWithObjects:
 [NSNumber numberWithInt:0], 
 [NSNumber numberWithFloat:(1 / self.bounds.size.height)], 
 [NSNumber numberWithFloat:(1 - (1 / self.bounds.size.height))], 
 [NSNumber numberWithInt:1], 
 nil];
 }
 else{
 UIColor* color = [selectedBackgroundStyle color];
 gradientView.gradientColors = [NSArray arrayWithObjects:color,color,nil];
 gradientView.gradientColorLocations = [NSArray arrayWithObjects:
 [NSNumber numberWithInt:0], 
 [NSNumber numberWithInt:1], 
 nil];
 }
 gradientView.alpha = [selectedBackgroundStyle alpha];
 gradientView.backgroundColor = [self parentControllerView:parentController].backgroundColor;
 
 CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
 switch([selectedBackgroundStyle cornerStyle]){
 case CKViewCornerStyleRounded:{
 roundedCornerType = CKRoundedCornerViewTypeAll;
 break;
 }
 case CKViewCornerStyleDefault:{
 UIView* parentView = [self parentControllerView:parentController];
 if([parentView isKindOfClass:[UITableView class]]){
 UITableView* tableView = (UITableView*)parentView;
 if(tableView.style == UITableViewStyleGrouped){
 NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
 if(indexPath.row == 0 && numberOfRows > 1){
 roundedCornerType = CKRoundedCornerViewTypeTop;
 }
 else if(indexPath.row == 0){
 roundedCornerType = CKRoundedCornerViewTypeAll;
 }
 else if(indexPath.row == numberOfRows-1){
 roundedCornerType = CKRoundedCornerViewTypeBottom;
 }
 }
 }
 break;
 }
 }
 
 gradientView.corners = roundedCornerType;
 gradientView.roundedCornerSize = [selectedBackgroundStyle cornerSize];
 }
 
 [appliedStack addObject:self.selectedBackgroundView];
 [self.selectedBackgroundView applySubViewsStyle:selectedBackgroundStyle appliedStack:appliedStack];
 */

@end
