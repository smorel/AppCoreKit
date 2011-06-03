//
//  CKUITableViewCell+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+Style.h"
#import "CKStyles.h"
#import "CKStyleManager.h"

//HACK : here to know the context of the parent controller ...
#import "CKObjectCarouselViewController.h"
#import "CKTableViewController.h"

#import "CKNSArrayAdditions.h"
#import "CKGradientView.h"
#import "CKStyle+Parsing.h"

NSString* CKStyleCellType = @"cellType";
NSString* CKStyleAccessoryType = @"accessoryType";

@implementation NSDictionary (CKUITableViewCellStyle)

- (UITableViewCellStyle)cellStyle{
	id object = [self objectForKey:CKStyleAccessoryType];
	if([object isKindOfClass:[NSString class]]){
		NSDictionary* dico = CKEnumDictionary(UITableViewCellStyleDefault, UITableViewCellStyleValue1, UITableViewCellStyleValue2,UITableViewCellStyleSubtitle);
		return [CKStyleParsing parseString:object toEnum:dico];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for cellStyle");
	return (object == nil) ? UITableViewCellStyleDefault : (UITableViewCellStyle)[object intValue];
}

- (UITableViewCellAccessoryType)accessoryType{
	id object = [self objectForKey:CKStyleAccessoryType];
	if([object isKindOfClass:[NSString class]]){
		NSDictionary* dico = CKEnumDictionary(UITableViewCellAccessoryNone, UITableViewCellAccessoryDisclosureIndicator, UITableViewCellAccessoryDetailDisclosureButton,UITableViewCellAccessoryCheckmark);
		return [CKStyleParsing parseString:object toEnum:dico];
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for accessoryType");
	return (object == nil) ? UITableViewCellAccessoryNone : (UITableViewCellAccessoryType)[object intValue];
}

@end

@implementation UITableViewCell (CKStyle)

//
- (UIView*)parentControllerView:(id)parentController{
	UIView* view = ([parentController isKindOfClass:[CKObjectCarouselViewController class]] == YES) ? 
	(UIView*)((CKObjectCarouselViewController*)parentController).carouselView 
	: (UIView*)((CKTableViewController*)parentController).tableView;
	return view;
}

- (void)applyStyle:(NSDictionary*)style atIndexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	NSMutableSet* appliedStack = [NSMutableSet set];
	NSDictionary* myViewStyle = [style styleForObject:self propertyName:@"tableViewCell"];
	if(myViewStyle){
		//Applying style on UITableViewCell
		if([myViewStyle containsObjectForKey:CKStyleAccessoryType]){
			self.accessoryType = [myViewStyle accessoryType];
		}
		[appliedStack addObject:self];
		
		[UILabel applyStyle:myViewStyle toView:self.textLabel propertyName:@"textLabel" appliedStack:appliedStack];
		[UILabel applyStyle:myViewStyle toView:self.detailTextLabel propertyName:@"detailTextLabel" appliedStack:appliedStack];
		[UIImageView applyStyle:myViewStyle toView:self.imageView propertyName:@"imageView" appliedStack:appliedStack];
		[UIView applyStyle:myViewStyle toView:self.backgroundView propertyName:@"backgroundView" appliedStack:appliedStack];
		[UIView applyStyle:myViewStyle toView:self.selectedBackgroundView propertyName:@"selectedBackgroundView" appliedStack:appliedStack];
		
		/*
		 if (self.backgroundColor) cell.backgroundColor             = (theStyle != nil) ? theStyle.backgroundColor : self.backgroundColor;
		 if (self.textColor) cell.textLabel.textColor               = (theStyle != nil) ? theStyle.textColor : self.textColor;
		 if (self.detailedTextColor) cell.detailTextLabel.textColor = (theStyle != nil) ? theStyle.detailedTextColor : self.detailedTextColor;
		 if ((theStyle != nil) ? theStyle.isTextMultiline : self.isTextMultiline) cell.textLabel.numberOfLines = 0;
		 if ((theStyle != nil) ? theStyle.isDetailTextMultiline : self.isDetailTextMultiline) cell.detailTextLabel.numberOfLines = 0;
		 
		 cell.imageView.image = self.fetchedImage ? self.fetchedImage : ((theStyle != nil) ? theStyle.image : self.image);
		 */
	}
	
	
	[self applySubViewsStyle:myViewStyle appliedStack:appliedStack];
}

@end


