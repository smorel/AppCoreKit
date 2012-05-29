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
#import "CKBindedCarouselViewController.h"
#import "CKTableViewController.h"
#import "CKBindedMapViewController.h"

#import "CKStyleView.h"
#import "CKNSArray+Additions.h"
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
                                                                        CKTableViewCellStyleIPadForm,
                                                                        CKTableViewCellStyleIPhoneForm,
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
    CKStyleView* backgroundView = nil;
    for(UIView* view in [self subviews]){
        if([view isKindOfClass:[CKStyleView class]]
           && view != self.backgroundView){
            backgroundView = (CKStyleView*)view;
            break;
        }
    }
    [super insertSubview:view atIndex:backgroundView ? index + 1 : index];
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

- (NSMutableDictionary*)applyStyle{
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	
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
    if(!self.containerController){
        return nil;
    }
    
    //CACHE THE STYLE FOR CELL CONTROLLERS AS IT IS PART OF THEIR REUSE IDENTIFIER
    NSMutableDictionary* style = [self appliedStyle];
    if(style){
        return style;
    }
    
	NSMutableDictionary* parentControllerStyle = [self.containerController controllerStyle];
	NSMutableDictionary* controllerStyle = [parentControllerStyle styleForObject:self  propertyName:nil];
    
    if([CKStyleManager logEnabled]){
        if([controllerStyle isEmpty]){
            CKDebugLog(@"did not find style for item controller %@ with parent controller %@ with style %@",self,self.containerController,parentControllerStyle);
        }
        else{
            CKDebugLog(@"found style for item controller %@",self);
        }
    }
    
    [self setAppliedStyle:controllerStyle];
    
	return controllerStyle;
}

- (UIView*)parentControllerView{
	UIView* view = nil;
	if([self.containerController isKindOfClass:[CKBindedCarouselViewController class]] == YES) 
		view = (UIView*)((CKBindedCarouselViewController*)self.containerController).carouselView;
	else if([self.containerController isKindOfClass:[CKTableViewController class]] == YES) 
		view = (UIView*)((CKTableViewController*)self.containerController).tableView;
	else if([self.containerController isKindOfClass:[CKBindedMapViewController class]] == YES) 
		view = (UIView*)((CKBindedMapViewController*)self.containerController).mapView;
	return view;
}

@end

//delegate for tableViewCell styles
@implementation CKTableViewCellController (CKStyle)

- (CKRoundedCornerViewType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style{
    CKViewCornerStyle cornerStyle = CKViewBorderStyleTableViewCell;
    if([style containsObjectForKey:CKStyleCornerStyle]){
        cornerStyle = [style cornerStyle];
    }
    
	CKRoundedCornerViewType roundedCornerType = CKRoundedCornerViewTypeNone;
	switch(cornerStyle){
		case CKViewCornerStyleTableViewCell:{
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
	
	return roundedCornerType;
}

- (CKStyleViewBorderLocation)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style{
	CKStyleViewBorderLocation borderType = CKStyleViewBorderLocationNone;
    
    CKViewBorderStyle borderStyle = CKViewBorderStyleTableViewCell;
    if([style containsObjectForKey:CKStyleBorderStyle]){
        borderStyle = [style borderStyle];
    }
	
	switch(borderStyle){
		case CKViewBorderStyleTableViewCell:{
			if(view == self.tableViewCell.backgroundView
			   || view == self.tableViewCell.selectedBackgroundView){
				UIView* parentView = [self parentControllerView];
				if([parentView isKindOfClass:[UITableView class]]){
					UITableView* tableView = (UITableView*)parentView;
                    NSInteger numberOfRows = [tableView numberOfRowsInSection:self.indexPath.section];
                    if(numberOfRows > 1){
                        if(self.indexPath.row == 0){
                            return  CKStyleViewBorderLocationAll &~ CKStyleViewBorderLocationBottom;
                        }else if(self.indexPath.row == numberOfRows-1){
                            return CKStyleViewBorderLocationAll &~ CKStyleViewBorderLocationTop;
                        }else{
                            return CKStyleViewBorderLocationLeft | CKStyleViewBorderLocationRight;
                        }
                    }
                    else{
                        return CKStyleViewBorderLocationAll;
                    }
				}
			}
			break;
		}
        case CKViewBorderStyleAll: return CKStyleViewBorderLocationAll;
        case CKViewBorderStyleNone: return CKStyleViewBorderLocationNone;
	}
	
	return borderType;
}

- (CKStyleViewSeparatorLocation)view:(UIView*)view separatorStyleWithStyle:(NSMutableDictionary*)style{
	CKStyleViewSeparatorLocation separatorType = CKStyleViewSeparatorLocationNone;
    
    CKViewSeparatorStyle separatorStyle = CKViewSeparatorStyleTableViewCell;
    if([style containsObjectForKey:CKStyleSeparatorStyle]){
        separatorStyle = [style separatorStyle];
    }
	
	switch(separatorStyle){
		case CKViewSeparatorStyleTableViewCell:{
			if(view == self.tableViewCell.backgroundView
			   || view == self.tableViewCell.selectedBackgroundView){
				UIView* parentView = [self parentControllerView];
				if([parentView isKindOfClass:[UITableView class]]){
					UITableView* tableView = (UITableView*)parentView;
                    NSInteger numberOfRows = [tableView numberOfRowsInSection:self.indexPath.section];
                    if(numberOfRows > 1 && self.indexPath.row != numberOfRows-1){
                        return CKStyleViewSeparatorLocationBottom;
                    }
                    else{
                        return CKStyleViewSeparatorLocationNone;
                    }
				}
			}
			break;
		}
        case CKViewSeparatorStyleTop:    return CKStyleViewSeparatorLocationAll;
        case CKViewSeparatorStyleBottom: return CKStyleViewSeparatorLocationBottom;
        case CKViewSeparatorStyleLeft:   return CKStyleViewSeparatorLocationLeft;
        case CKViewSeparatorStyleRight:  return CKStyleViewSeparatorLocationRight;
	}
	
	return separatorType;
}


- (UIColor*)separatorColorForView:(UIView*)view withStyle:(NSMutableDictionary*)style{
    BOOL hasSeparator = ([[self parentTableView]separatorStyle] != UITableViewCellSeparatorStyleNone);
    UIColor* separatorColor = hasSeparator ? [[self parentTableView]separatorColor] : [UIColor clearColor];
    if([style containsObjectForKey:CKStyleSeparatorColor]){
        separatorColor = [style separatorColor];
    }
    return separatorColor;
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