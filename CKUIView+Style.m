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

NSString* CKStyleColor = @"color";
NSString* CKStyleGradientColors = @"gradientColors";
NSString* CKStyleGradientLocations = @"gradientLocations";
NSString* CKStyleImage = @"image";
NSString* CKStyleCornerStyle = @"cornerStyle";
NSString* CKStyleCornerSize = @"cornerSize";
NSString* CKStyleAlpha = @"alpha";

@implementation NSDictionary (CKViewStyle)

- (UIColor*)color{
	id object = [self objectForKey:CKStyleColor];
	if([object isKindOfClass:[NSString class]]){
		return [CKStyleParsing parseStringToColor:object];
	}
	NSAssert(object == nil || [object isKindOfClass:[UIColor class]],@"invalid class for backgroundColor");
	return (object == nil) ? [UIColor whiteColor] : (UIColor*)object;
}

- (NSArray*)gradientColors{
	id object = [self objectForKey:CKStyleGradientColors];
	NSAssert(object == nil || [object isKindOfClass:[NSArray class]],@"invalid class for backgroundGradientColors");
	NSMutableArray* values = [NSMutableArray array];
	for(id value in object){
		if([value isKindOfClass:[NSString class]]){
			[values addObject:[CKStyleParsing parseStringToColor:value]];
		}
		else{
			NSAssert([value isKindOfClass:[UIColor class]],@"invalid class for color");
			[values addObject:value];
		}
	}
	return values;
}

- (NSArray*)gradientLocations{
	id object = [self objectForKey:CKStyleGradientLocations];
	NSAssert(object == nil || [object isKindOfClass:[NSArray class]],@"invalid class for backgroundGradientLocations");
	NSMutableArray* values = [NSMutableArray array];
	for(id value in object){
		if([value isKindOfClass:[NSString class]]){
			[values addObject:[NSNumber numberWithFloat:[value floatValue]]];
		}
		else{
			NSAssert([value isKindOfClass:[NSNumber class]],@"invalid class for color position");
			[values addObject:value];
		}
	}
	return values;
}

- (UIImage*)image{
	id object = [self objectForKey:CKStyleImage];
	if([object isKindOfClass:[NSString class]]){
		UIImage* image = [UIImage imageNamed:object];
		return image;
	}
	else if([object isKindOfClass:[NSURL class]]){
		NSURL* url = (NSURL*)object;
		if([url isFileURL]){
			UIImage* image = [UIImage imageWithContentsOfFile:[url path]];
			return image;
		}
		NSAssert(NO,@"Styles only supports file url yet");
		return nil;
	}
	
	NSAssert(object == nil || [object isKindOfClass:[UIImage class]],@"invalid class for backgroundImage");
	return (UIImage*)object;
} 

- (CKViewCornerStyle)cornerStyle{
	id object = [self objectForKey:CKStyleCornerStyle];
	if([object isKindOfClass:[NSString class]]){
		NSDictionary* dico = CKEnumDictionary(CKViewCornerStyleDefault, CKViewCornerStyleRounded, CKViewCornerStylePlain);
		return [CKStyleParsing parseString:object toEnum:dico];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for cornerStyle");
	return (object == nil) ? CKViewCornerStyleDefault : (CKViewCornerStyle)[object intValue];
}

- (CGSize)cornerSize{
	id object = [self objectForKey:CKStyleCornerSize];
	if([object isKindOfClass:[NSString class]]){
		return [CKStyleParsing parseStringToCGSize:object];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cornerSize");
	return (object == nil) ? CGSizeMake(10,10) : [object CGSizeValue];
}

- (CGFloat)alpha{
	id object = [self objectForKey:CKStyleAlpha];
	if([object isKindOfClass:[NSString class]]){
		return [object floatValue];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for alpha");
	return (object == nil) ? 11 : [object floatValue];
}

@end

@implementation UIView (CKStyle)

+ (NSDictionary*)defaultStyle{
	NSAssert(NO,@"Not Implemented");
	return nil;
}

- (void)applyStyle:(NSDictionary*)style{
	[self applyStyle:style propertyName:@""];
}

- (void)applyStyle:(NSDictionary*)style propertyName:(NSString*)propertyName{
	[[self class] applyStyle:style toView:self propertyName:propertyName appliedStack:[NSMutableSet set]];
}

+ (BOOL)applyStyle:(NSDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack
                   cornerModifierTarget:(id)target cornerModifierAction:(SEL)action {
	if(view == nil)
		return NO;
	
	NSDictionary* myViewStyle = [style styleForObject:view propertyName:propertyName];
	if(myViewStyle){
		if([appliedStack containsObject:view] == NO){
			UIView* backgroundView = view;
			if([myViewStyle containsObjectForKey:CKStyleGradientColors]
			   || [myViewStyle containsObjectForKey:CKStyleCornerStyle]
			   || [myViewStyle containsObjectForKey:CKStyleImage]){
				
				CKGradientView* gradientView = [[[CKGradientView alloc]initWithFrame:view.bounds]autorelease];
				gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				gradientView.backgroundColor = [UIColor clearColor];
				view.backgroundColor = [UIColor clearColor];
				
				if([myViewStyle containsObjectForKey:CKStyleImage]){
					gradientView.image = [myViewStyle image];
				}
				
				if([myViewStyle containsObjectForKey:CKStyleGradientColors]){
					gradientView.gradientColors = [myViewStyle gradientColors];
				}
				if([myViewStyle containsObjectForKey:CKStyleGradientLocations]){
					gradientView.gradientColorLocations = [myViewStyle gradientLocations];
				}
				
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
							/*case CKViewCornerStyleDefault:{
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
							 }*/
					}
				}
				
				gradientView.corners = roundedCornerType;
				
				if([myViewStyle containsObjectForKey:CKStyleCornerSize]){
					gradientView.roundedCornerSize = [myViewStyle cornerSize];
				}
				
				backgroundView = gradientView;
				[view insertSubview:gradientView atIndex:0];
			}
			
			if([myViewStyle containsObjectForKey:CKStyleAlpha])
				backgroundView.alpha = [myViewStyle alpha];
			
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
				}
				else{
					backgroundView.backgroundColor = [myViewStyle color];
				}
			}
			
			[appliedStack addObject:view];
			return YES;
		}
	}
	[view applySubViewsStyle:myViewStyle appliedStack:appliedStack];
	return NO;
}


+ (BOOL)applyStyle:(NSDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	return [self applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack  cornerModifierTarget:nil cornerModifierAction:nil];
}

- (void)applySubViewsStyle:(NSDictionary*)style appliedStack:(NSMutableSet*)appliedStack{
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
