//
//  CKTableViewCellController+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController+Style.h"
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

@implementation NSDictionary (CKTableViewCellControllerStyle)

- (UITableViewCellStyle)cellStyle{
	id object = [self objectForKey:CKStyleCellType];
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

@implementation CKTableViewCellController (CKStyle)

- (NSDictionary*)controllerStyle{
	NSDictionary* parentControllerStyle = [[CKStyleManager defaultManager] styleForObject:self.parentController  propertyName:@""];
	NSDictionary* controllerStyle = [parentControllerStyle styleForObject:self  propertyName:@""];
	return controllerStyle;
}

//
- (UIView*)parentControllerView{
	UIView* view = ([self.parentController isKindOfClass:[CKObjectCarouselViewController class]] == YES) ? 
	(UIView*)((CKObjectCarouselViewController*)self.parentController).carouselView 
	: (UIView*)((CKTableViewController*)self.parentController).tableView;
	return view;
}

//[self controllerStyle] atIndexPath:self.indexPath parentController:self.parentController];

- (NSNumber*)computeCornerStyle:(NSDictionary*)style{
	CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
	
	switch([style cornerStyle]){
		case CKViewCornerStyleRounded:{
			roundedCornerType = CKRoundedCornerViewTypeAll;
			break;
		}
		case CKViewCornerStyleDefault:{
			UIView* parentView = [self parentControllerView];
			if([parentView isKindOfClass:[UITableView class]]){
				UITableView* tableView = (UITableView*)parentView;
				if(tableView.style == UITableViewStyleGrouped){
					NSInteger numberOfRows = [tableView numberOfRowsInSection:self.indexPath.section];
					if(self.indexPath.row == 0 && numberOfRows > 1){
						roundedCornerType = CKRoundedCornerViewTypeTop;
					}
					else if(self.indexPath.row == 0){
						roundedCornerType = CKRoundedCornerViewTypeAll;
					}
					else if(self.indexPath.row == numberOfRows-1){
						roundedCornerType = CKRoundedCornerViewTypeBottom;
					}
				}
			}
			break;
		}
	}
	
	return [NSNumber numberWithInt:roundedCornerType];
}

- (void)applyStyle{
	UITableViewCell* cell = self.tableViewCell;
	
	NSMutableSet* appliedStack = [NSMutableSet set];
	NSDictionary* controllerStyle = [self controllerStyle];
	if(controllerStyle){
		//Applying style on UITableViewCell
		if([controllerStyle containsObjectForKey:CKStyleAccessoryType]){
			cell.accessoryType = [controllerStyle accessoryType];
		}
		[appliedStack addObject:cell];
		
		[UILabel applyStyle:controllerStyle toView:cell.textLabel propertyName:@"textLabel" appliedStack:appliedStack];
		[UILabel applyStyle:controllerStyle toView:cell.detailTextLabel propertyName:@"detailTextLabel" appliedStack:appliedStack];
		[UIImageView applyStyle:controllerStyle toView:cell.imageView propertyName:@"imageView" appliedStack:appliedStack];
		
		cell.backgroundView = [[[UIView alloc]initWithFrame:cell.bounds]autorelease];
		cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[UIView applyStyle:controllerStyle toView:cell.backgroundView propertyName:@"backgroundView" appliedStack:appliedStack cornerModifierTarget:self cornerModifierAction:@selector(computeCornerStyle:)];
		
		cell.selectedBackgroundView = [[[UIView alloc]initWithFrame:cell.bounds]autorelease];
		cell.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[UIView applyStyle:controllerStyle toView:cell.selectedBackgroundView propertyName:@"selectedBackgroundView" appliedStack:appliedStack cornerModifierTarget:self cornerModifierAction:@selector(computeCornerStyle:)];
	}
	
	[cell applySubViewsStyle:controllerStyle appliedStack:appliedStack];
}


@end

