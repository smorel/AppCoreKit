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
NSString* CKStyleAccessoryImage = @"accessoryImage";
NSString* CKStyleCellSize = @"size";
NSString* CKStyleCellFlags = @"flags";

@implementation NSMutableDictionary (CKTableViewCellControllerStyle)

- (UITableViewCellStyle)cellStyle{
	return (UITableViewCellStyle)[self enumValueForKey:CKStyleCellType 
									 withDictionary:CKEnumDictionary(UITableViewCellStyleDefault, 
																	 UITableViewCellStyleValue1, 
																	 UITableViewCellStyleValue2,
																	 UITableViewCellStyleSubtitle)];
}

- (UITableViewCellAccessoryType)accessoryType{
	return (UITableViewCellAccessoryType)[self enumValueForKey:CKStyleAccessoryType 
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

- (UIImage*)accessoryImage{
	return [self imageForKey:CKStyleAccessoryImage];
}

- (CGSize)cellSize{
	return [self cgSizeForKey:CKStyleCellSize];
}

- (CKTableViewCellFlags)cellFlags{
	return (CKTableViewCellFlags)[self enumValueForKey:CKStyleCellFlags 
										withDictionary:CKEnumDictionary(CKTableViewCellFlagNone,
																		CKTableViewCellFlagSelectable,
																		CKTableViewCellFlagEditable,
																		CKTableViewCellFlagRemovable,
																		CKTableViewCellFlagMovable,
																		CKTableViewCellFlagAll)];
}

@end

@implementation CKTableViewCellController (CKStyle)

- (NSMutableDictionary*)controllerStyle{
	NSMutableDictionary* parentControllerStyle = [[CKStyleManager defaultManager] styleForObject:self.parentController  propertyName:nil];
	NSMutableDictionary* controllerStyle = [parentControllerStyle styleForObject:self  propertyName:nil];
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

- (CKGradientViewBorderType)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style{
	CKGradientViewBorderType borderType = CKGradientViewBorderTypeNone;
	
	switch([style cornerStyle]){
		case CKViewCornerStyleDefault:{
			if(view == self.tableViewCell.backgroundView
			   || view == self.tableViewCell.selectedBackgroundView){
				UIView* parentView = [self parentControllerView];
				if([parentView isKindOfClass:[UITableView class]]){
					UITableView* tableView = (UITableView*)parentView;
					if(tableView.style == UITableViewStyleGrouped){
						NSInteger numberOfRows = [tableView numberOfRowsInSection:self.indexPath.section];
						if(self.indexPath.row == numberOfRows - 1){
							borderType = CKGradientViewBorderTypeAll;
						}
						else {
							borderType = CKGradientViewBorderTypeAll &~ CKGradientViewBorderTypeBottom;
						}
					}
					else{
						borderType = CKGradientViewBorderTypeBottom;
					}
				}
			}
			break;
		}
	}
	
	return borderType;
}

- (BOOL)object:(id)object shouldReplaceViewWithDescriptor:(CKClassPropertyDescriptor*)descriptor withStyle:(NSMutableDictionary*)style{
	if(style == nil || [style isEmpty] == YES)
		return NO;
	
	if([object isKindOfClass:[UITableViewCell class]]){
		if(([descriptor.name isEqual:@"backgroundView"]
		   || [descriptor.name isEqual:@"selectedBackgroundView"]) && [style isEmpty] == NO){
			return YES;
		}
	}
	return NO;
}

- (void)applyStyle:(NSMutableDictionary*)style forCell:(UITableViewCell*)cell{
	if([[[self class]description]isEqual:@"RXInterventionTableViewCellController"] == YES){
		int i = 3;
	}
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:style appliedStack:appliedStack delegate:self];
}

@end


@implementation UITableViewCell (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UITableViewCell* tableViewCell = (UITableViewCell*)view;
		NSMutableDictionary* myCellStyle = style;
		if(myCellStyle){
			//Applying style on UITableViewCell
			if([myCellStyle containsObjectForKey:CKStyleAccessoryImage]){
				UIImage* image = [myCellStyle accessoryImage];
				UIImageView* imageView = [[[UIImageView alloc]initWithImage:image]autorelease];
				tableViewCell.accessoryView = imageView;
			}
			else if([myCellStyle containsObjectForKey:CKStyleAccessoryType]){
				tableViewCell.accessoryType = [myCellStyle accessoryType];
			}
			if([myCellStyle containsObjectForKey:CKStyleSelectionStyle]){
				tableViewCell.selectionStyle = [myCellStyle selectionStyle];
			}
			return YES;
		}
	}
	return NO;
}


@end

@implementation CKTableViewController (CKStyle)

- (BOOL)object:(id)object shouldReplaceViewWithDescriptor:(CKClassPropertyDescriptor*)descriptor withStyle:(NSMutableDictionary*)style{
	if(style == nil || [style isEmpty] == YES)
		return NO;
	
	if([object isKindOfClass:[UITableView class]]){
		if([descriptor.name isEqual:@"backgroundView"] && [style isEmpty] == NO){
			return YES;
		}
	}
	return NO;
}

- (void)applyStyle{
	NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
	
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:self];
}


@end

