//
//  CKTableViewCellController+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController+Style.h"
#import "CKStyleManager.h"

//HACK : here to know the context of the parent controller ...
#import "CKObjectCarouselViewController.h"
#import "CKTableViewController.h"
#import "CKMapViewController.h"

#import "CKGradientView.h"
#import "CKNSArrayAdditions.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"

NSString* CKStyleCellType = @"cellType";
NSString* CKStyleAccessoryImage = @"accessoryImage";
NSString* CKStyleCellSize = @"size";
NSString* CKStyleCellFlags = @"flags";

@implementation NSMutableDictionary (CKTableViewCellControllerStyle)

- (CKTableViewCellStyle)cellStyle{
	return (CKTableViewCellStyle)[self enumValueForKey:CKStyleCellType 
                                    withEnumDescriptor:CKEnumDefinition(@"CKTableViewCellStyle",
                                                                        CKTableViewCellStyleDefault,
                                                                        UITableViewCellStyleDefault,
                                                                        CKTableViewCellStyleValue1,
                                                                        UITableViewCellStyleValue1,
                                                                        CKTableViewCellStyleValue2,
                                                                        UITableViewCellStyleValue2,
                                                                        CKTableViewCellStyleSubtitle,
                                                                        UITableViewCellStyleSubtitle,
                                                                        CKTableViewCellStyleValue3,
                                                                        CKTableViewCellStylePropertyGrid,
                                                                        CKTableViewCellStyleSubtitle2)];
}

- (UIImage*)accessoryImage{
	return [self imageForKey:CKStyleAccessoryImage];
}

- (CGSize)cellSize{
	return [self cgSizeForKey:CKStyleCellSize];
}

- (CKItemViewFlags)cellFlags{
	return (CKItemViewFlags)[self enumValueForKey:CKStyleCellFlags 
										withEnumDescriptor:CKEnumDefinition(@"CKItemViewFlags",
                                                                            CKItemViewFlagNone,
																		CKItemViewFlagSelectable,
																		CKItemViewFlagEditable,
																		CKItemViewFlagRemovable,
																		CKItemViewFlagMovable,
																		CKItemViewFlagAll,
																		CKTableViewCellFlagNone,
																		CKTableViewCellFlagSelectable,
																		CKTableViewCellFlagEditable,
																		CKTableViewCellFlagRemovable,
																		CKTableViewCellFlagMovable,
																		CKTableViewCellFlagAll)];
}

@end


@implementation UITableViewCell (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate{
    //NSLog(@"apply style on UITableViewCell : %@",self);
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
			return YES;
		}
	}
	return NO;
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    CKGradientView* backgroundView = nil;
    for(UIView* view in [self subviews]){
        if([view isKindOfClass:[CKGradientView class]]
           && view != self.backgroundView){
            backgroundView = (CKGradientView*)view;
            break;
        }
    }
    [super insertSubview:view atIndex:backgroundView ? index + 1 : index];
}

/*
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    UIColor* previousColor = nil;
    object_getInstanceVariable(self, "_backgroundColor", (void **)(&previousColor));
    [previousColor release];
    object_setInstanceVariable(self, "_backgroundColor", (void**)([backgroundColor retain]));

    //bypass the custom set background color of UITableViewCell
    [super setBackgroundColor:backgroundColor];
}
*/

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

- (NSMutableDictionary*)applyStyle{
	NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
	
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:self];
    return controllerStyle;
}

@end


@implementation CKItemViewController (CKStyle)

- (void)applyStyle:(NSMutableDictionary*)style forView:(UIView*)view{
    //NSLog(@"apply style on CKItemViewController : %@",self);
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:style appliedStack:appliedStack delegate:self];
}

- (NSMutableDictionary*)controllerStyle{
	NSMutableDictionary* parentControllerStyle = [[CKStyleManager defaultManager] styleForObject:self.parentController  propertyName:nil];
	NSMutableDictionary* controllerStyle = [parentControllerStyle styleForObject:self  propertyName:nil];
    
    if([CKStyleManager logEnabled]){
        if([controllerStyle isEmpty]){
            CKDebugLog(@"did not find style for item controller %@ with parent controller %@ with style %@",self,self.parentController,parentControllerStyle);
        }
        else{
            CKDebugLog(@"found style for item controller %@",self);
        }
    }
    
	return controllerStyle;
}

- (UIView*)parentControllerView{
	UIView* view = nil;
	if([self.parentController isKindOfClass:[CKObjectCarouselViewController class]] == YES) 
		view = (UIView*)((CKObjectCarouselViewController*)self.parentController).carouselView;
	else if([self.parentController isKindOfClass:[CKTableViewController class]] == YES) 
		view = (UIView*)((CKTableViewController*)self.parentController).tableView;
	else if([self.parentController isKindOfClass:[CKMapViewController class]] == YES) 
		view = (UIView*)((CKMapViewController*)self.parentController).mapView;
	return view;
}

@end

//delegate for tableViewCell styles
@implementation CKTableViewCellController (CKStyle)

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

@end


@implementation UITableView (CKStyle)

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    if([view isKindOfClass:[UITableViewCell class]]){
        id dataSource = [self dataSource];
        if([dataSource isKindOfClass:[CKItemViewContainerController class]]){
            CKItemViewContainerController* controller = (CKItemViewContainerController*)dataSource;
            NSIndexPath* indexPath = [controller indexPathForView:view];
            if(indexPath.row > 0){
                NSIndexPath* previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row -1 inSection:indexPath.section];
                UIView* previousView = [controller viewAtIndexPath:previousIndexPath];
                NSInteger index = previousView ? [[self subviews]indexOfObjectIdenticalTo:previousView] : NSNotFound;
                if(index != NSNotFound){
                    [super insertSubview:view atIndex:index+1];
                    return;
                }
                else{
                    NSInteger count = [controller numberOfObjectsForSection:indexPath.section];
                    if(indexPath.row < count){
                        NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                        if([controller isValidIndexPath:nextIndexPath]){
                            UIView* nextView = [controller viewAtIndexPath:nextIndexPath];
                            NSInteger index = nextView ? [[self subviews]indexOfObjectIdenticalTo:nextView] : NSNotFound;
                            if(index != NSNotFound){
                                [super insertSubview:view atIndex:index];
                                return;
                            }
                        }
                    }
                    else{
                        NSInteger sectionCount = [controller numberOfSections];
                        if(indexPath.section < (sectionCount - 1)){
                            NSInteger section = indexPath.section + 1;
                            UIView* headerView = [controller.objectController headerViewForSection:section];
                            //TODO find the headerView if headerTitle !
                            if(headerView){
                                NSInteger index = [[self subviews]indexOfObjectIdenticalTo:headerView];
                                if(index != NSNotFound){
                                    [super insertSubview:view atIndex:index];
                                    return;
                                }
                            }
                            else{
                                NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                                if([controller isValidIndexPath:nextIndexPath]){
                                    UIView* nextView = [controller viewAtIndexPath:nextIndexPath];
                                    NSInteger index = nextView ? [[self subviews]indexOfObjectIdenticalTo:nextView] : NSNotFound;
                                    if(index != NSNotFound){
                                        [super insertSubview:view atIndex:index];
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else{
                NSInteger section = indexPath.section;
                UIView* headerView = [controller.objectController headerViewForSection:section];
                //TODO find the headerView if headerTitle !
                if(headerView){
                    NSInteger index = [[self subviews]indexOfObjectIdenticalTo:headerView];
                    if(index != NSNotFound){
                        [super insertSubview:view atIndex:index + 1];
                        return;
                    }
                }
                else{
                    NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:([controller numberOfObjectsForSection:section-1] - 1) inSection:section-1];
                    if([controller isValidIndexPath:nextIndexPath]){
                        UIView* nextView = [controller viewAtIndexPath:nextIndexPath];
                        NSInteger index = nextView ? [[self subviews]indexOfObjectIdenticalTo:nextView] : NSNotFound;
                        if(index != NSNotFound){
                            [super insertSubview:view atIndex:index + 1];
                            return;
                        }
                    }
                }
            }
        }
    }
    [super insertSubview:view atIndex:index];
}

@end