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

- (CKRoundedCornerViewType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style{
	CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
	
	switch([style cornerStyle]){
		case CKViewCornerStyleDefault:{
			if(view == self.tableViewCell.backgroundView
			   || view == self.tableViewCell.selectedBackgroundView){
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
			}
			break;
		}
	}
	
	return roundedCornerType;
}

- (BOOL)object:(id)object shouldReplaceViewWithDescriptor:(CKClassPropertyDescriptor*)descriptor{
	if([object isKindOfClass:[UITableViewCell class]]){
		if([descriptor.name isEqual:@"backgroundView"]
		   || [descriptor.name isEqual:@"selectedBackgroundView"]){
			return YES;
		}
	}
	return NO;
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
	}
	
	[self applySubViewsStyle:style appliedStack:appliedStack delegate:self];
}

@end

