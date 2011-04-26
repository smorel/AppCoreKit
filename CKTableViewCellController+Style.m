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

#import "CKGradientView.h"
#import "CKNSArrayAdditions.h"
#import "CKStyle+Parsing.h"

NSString* CKStyleCellType = @"cellType";
NSString* CKStyleAccessoryType = @"accessoryType";
NSString* CKStyleSelectionStyle = @"selectionStyle";

@implementation NSMutableDictionary (CKTableViewCellControllerStyle)

- (UITableViewCellStyle)cellStyle{
	return (UITableViewCellStyle)[self enumValueForKey:CKStyleCellType 
									 withDictionary:CKEnumDictionary(UITableViewCellStyleDefault, 
																	 UITableViewCellStyleValue1, 
																	 UITableViewCellStyleValue2,
																	 UITableViewCellStyleSubtitle)];
}

- (UITableViewCellAccessoryType)accessoryType{
	return (UITableViewCellAccessoryType)[self enumValueForKey:CKStyleCellType 
									 withDictionary:CKEnumDictionary(UITableViewCellAccessoryNone, 
																	 UITableViewCellAccessoryDisclosureIndicator, 
																	 UITableViewCellAccessoryDetailDisclosureButton,
																	 UITableViewCellAccessoryCheckmark)];
}

- (UITableViewCellSelectionStyle)selectionStyle{
	return (UITableViewCellSelectionStyle)[self enumValueForKey:CKStyleSelectionStyle 
												withDictionary:CKEnumDictionary(UITableViewCellSelectionStyleNone,
																				UITableViewCellSelectionStyleBlue,
																				UITableViewCellSelectionStyleGray)];

}

@end

@implementation CKTableViewCellController (CKStyle)

- (NSMutableDictionary*)controllerStyle{
	NSMutableDictionary* parentControllerStyle = [[CKStyleManager defaultManager] styleForObject:self.parentController  propertyName:@""];
	NSMutableDictionary* controllerStyle = [parentControllerStyle styleForObject:self  propertyName:@""];
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

- (NSNumber*)computeCornerStyle:(NSMutableDictionary*)style{
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

- (void)applyStyle:(NSMutableDictionary*)style forCell:(UITableViewCell*)cell{
	NSMutableSet* appliedStack = [NSMutableSet set];
	if(style){
		//Applying style on UITableViewCell
		if([style containsObjectForKey:CKStyleAccessoryType]){
			cell.accessoryType = [style accessoryType];
		}
		if([style containsObjectForKey:CKStyleSelectionStyle]){
			cell.selectionStyle = [style selectionStyle];
		}
		[appliedStack addObject:cell];
		
		[UILabel applyStyle:style toView:cell.textLabel propertyName:@"textLabel" appliedStack:appliedStack];
		[UILabel applyStyle:style toView:cell.detailTextLabel propertyName:@"detailTextLabel" appliedStack:appliedStack];
		[UIImageView applyStyle:style toView:cell.imageView propertyName:@"imageView" appliedStack:appliedStack];
		
		if([UIView needSubView:style forView:cell.backgroundView propertyName:@"backgroundView"] && [cell.backgroundView isKindOfClass:[CKGradientView class]] == NO){
			cell.backgroundView = [[[CKGradientView alloc]initWithFrame:cell.bounds]autorelease];
			cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		[UIView applyStyle:style toView:cell.backgroundView propertyName:@"backgroundView" appliedStack:appliedStack cornerModifierTarget:self cornerModifierAction:@selector(computeCornerStyle:)];
		
		if([UIView needSubView:style forView:cell.backgroundView propertyName:@"selectedBackgroundView"] && [cell.selectedBackgroundView isKindOfClass:[CKGradientView class]] == NO){
			cell.selectedBackgroundView = [[[CKGradientView alloc]initWithFrame:cell.bounds]autorelease];
			cell.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		[UIView applyStyle:style toView:cell.selectedBackgroundView propertyName:@"selectedBackgroundView" appliedStack:appliedStack cornerModifierTarget:self cornerModifierAction:@selector(computeCornerStyle:)];
	}
	
	[cell applySubViewsStyle:style appliedStack:appliedStack];
}

@end

