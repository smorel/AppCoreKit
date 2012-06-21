//
//  CKGridTableViewCellController.m
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKGridTableViewCellController.h"
#import "CKGridView.h"
#import "CKStyleView.h"
#import "CKNSObject+Bindings.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import "CKGridCollectionViewController.h"

#define InteractionButtonTag 3457
#define ControllerViewBaseTag 3458

@interface CKCollectionCellController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@end

@interface CKGridTableViewCellController()
- (void)updateViewControllers;
@end

//TODO : Manage touch on contentView to dispatch selection to sub controllers
//       Manage reuse of cellController's views

@implementation CKGridTableViewCellController
@synthesize controllerFactory = _controllerFactory;
@synthesize numberOfColumns = _numberOfColumns;
@synthesize cellControllers = _cellControllers;

- (void)postInit{
    [super postInit];
    _numberOfColumns = 2;
    self.flags = CKItemViewFlagNone;
}

- (void)dealloc{
    [_cellControllers release];
    [_controllerFactory release];
    [super dealloc];
}

- (void)setValue:(id)value{
    NSAssert([value isKindOfClass:[NSArray class]],@"invalid value");
    [super setValue:value];
    
    [self updateViewControllers];
    
    if([self tableViewCell]){
        [self setupCell:self.tableViewCell];
    }
}

- (void)setIndexPath:(NSIndexPath*)indexPath{
    [super setIndexPath:indexPath];
    
    for(int i =0; i< _numberOfColumns; ++i){
        if([self.cellControllers count] > i){
            /*NSUInteger indexes[3];
            indexes[0] = self.indexPath.row;
            indexes[1] = self.indexPath.section;
            indexes[2] = i;
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:indexes length:3];
             */
            
            NSIndexPath* indexPath = self.indexPath;
            
            CKCollectionCellController* controller = [self.cellControllers objectAtIndex:i];
            [controller setIndexPath:indexPath];
        }
    }
}

- (void)setNumberOfColumns:(NSInteger)n{
    _numberOfColumns = n;
    
    if([self tableViewCell]){
        [self setupCell:self.tableViewCell];
    }
}

- (void)setupCell:(UITableViewCell *)cell{
    [super setupCell:cell];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    
    //Hides the view that have been inserted and that are not used anymore.
    NSInteger totalViews = 0;
    NSInteger viewTag = ControllerViewBaseTag + totalViews;
    UIView* view = [cell.contentView viewWithTag:viewTag];
    while(view){
        ++totalViews;
        viewTag = ControllerViewBaseTag + totalViews;
        view = [cell.contentView viewWithTag:viewTag];
    }
    
    for(int i =_numberOfColumns - 1;i<=totalViews; ++i){
        viewTag = ControllerViewBaseTag + i;
        view = [cell.contentView viewWithTag:viewTag];
        if(view)view.hidden = YES;
    }

    
    [cell beginBindingsContextByRemovingPreviousBindings];
    
    for(int i =0; i< _numberOfColumns; ++i){
        NSInteger viewTag = ControllerViewBaseTag + i;
        UIView* view = [cell.contentView viewWithTag:viewTag];
        NSAssert(!view || [view isKindOfClass:[CKUITableViewCell class]],@"Invalid view class");
        
        CKUITableViewCell* subcell = (CKUITableViewCell*)view;
        if(i < [self.cellControllers count]){
            //HERE WE ASSUME WE ONLY HAVE 1 TYPE OF CELLS IN GRIDS AND REUSE THE EXISTING VIEWS
            NSInteger index = i;
            CKTableViewCellController* controller = [self.cellControllers objectAtIndex:index];
            if(subcell){
                CKTableViewCellController* oldController = [subcell delegate];
                [oldController setView:nil];
                [controller setView:subcell];
            }else{
                //Creates and insert cell
                CKTableViewCellController* controller = [self.cellControllers objectAtIndex:index];
                UIView* view = [controller loadView];
                view.tag = viewTag;
                
                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = view.bounds;
                button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                button.tag = InteractionButtonTag;
                
                NSInteger styleViewIndex = -1;
                int i = 0;
                for(UIView* v in [view subviews]){
                    if([v isKindOfClass:[CKStyleView class]]){
                        styleViewIndex = i;
                        break;
                    }
                    ++i;
                }
                [view insertSubview:button atIndex:(styleViewIndex == -1) ? 0 : styleViewIndex+1];
                
                [controller setView:view];
                
                [cell.contentView addSubview:view];
                
                subcell = (CKUITableViewCell*) view;
            }
            
            subcell.contentView.userInteractionEnabled = NO;
            
            UIButton* button = (UIButton*)[subcell viewWithTag:InteractionButtonTag];
            button.backgroundColor = [UIColor clearColor];
            
            if([controller flags] & CKItemViewFlagSelectable){
                [button bindEvent:UIControlEventTouchDown withBlock:^{
                    if([[controller willSelect] isEqual:[controller indexPath]]){
                        [controller.tableViewCell setSelected:YES animated:NO];
                        [controller.tableViewCell setHighlighted:YES animated:NO];
                    }
                }];
                [button bindEvent:UIControlEventTouchDragInside withBlock:^{
                    //FIXME : THIS IS TOO MUCH SENSIBLE : As table views, we should disable if drag 5px up or down from the original touch ...
                    button.enabled = NO;
                    if([[controller willSelect] isEqual:[controller indexPath]]){
                        [controller.tableViewCell setSelected:NO animated:NO];
                        [controller.tableViewCell setHighlighted:NO animated:NO];
                    }
                }];
                [button bindEvent:UIControlEventTouchUpInside withBlock:^{
                    if(button.enabled){
                        [controller didSelect];
                    }
                    button.enabled = YES; 
                }];
                [button bindEvent:UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragOutside withBlock:^{
                    if(button.enabled){
                        [controller.tableViewCell setSelected:NO animated:NO];
                        [controller.tableViewCell setHighlighted:NO animated:NO];
                    }
                    button.enabled = YES;
                }];
            }
            
            subcell.hidden = NO;
            [controller performSelector:@selector(setContainerController:) withObject:self.containerController];
            [controller setupView:subcell];
        }else{
            subcell.hidden = YES;
        }
    }
    
    [cell endBindingsContext];
    
    [UIView setAnimationsEnabled:NO];
    [self layoutCell:cell];
    [UIView setAnimationsEnabled:YES];
}

- (void)updateViewControllers{
    NSMutableArray* controllers = [NSMutableArray array];
    
    CKGridCollectionViewController* parentGrid = (CKGridCollectionViewController*)self.containerController;
    
    NSArray* objects = (NSArray*)self.value;
    int i =0;
    for(id object in objects){
        CKTableViewCellController* controller = (CKTableViewCellController*)[parentGrid subControllerForRow:self.indexPath.row column:i];
        controller.parentCellController = self;
        [controllers addObject:controller];
        ++i;
    }
    
    self.cellControllers = controllers;
}


- (void)layoutCell:(UITableViewCell *)cell{
    //TODO : layout vertically vs. horizontally
    //switch(self.parentTableViewController.orientation){
    //}
    
    CGFloat viewWidth = (cell.contentView.frame.size.width - self.contentInsets.left - self.contentInsets.right - ((_numberOfColumns - 1) * self.componentsSpace)) / (CGFloat)_numberOfColumns;
    for(int i =0; i< _numberOfColumns; ++i){
        NSInteger viewTag = ControllerViewBaseTag + i;
        UIView* view = [cell.contentView viewWithTag:viewTag];
        if(view){
            view.hidden = (i >= [self.cellControllers count]);
            CGFloat x = self.contentInsets.left + (i * (viewWidth + self.componentsSpace));
            view.frame = CGRectIntegral(CGRectMake(x,self.contentInsets.top,viewWidth,cell.frame.size.height - (self.contentInsets.top + self.contentInsets.bottom)));
        }
    }
}

- (void)viewDidAppear:(UIView *)view{
    [super viewDidAppear:view];
    for(CKCollectionCellController* controller in self.cellControllers){
        [controller viewDidAppear:view];
    }
}

- (void)viewDidDisappear{
    [super viewDidDisappear];
    for(CKCollectionCellController* controller in self.cellControllers){
        [controller viewDidDisappear];
    }
}

- (CGFloat)computeContentViewSizeForSubCellController{
    CGFloat contentWidth = [self computeContentViewSize];
    
    CGFloat viewWidth = (contentWidth - self.contentInsets.left - self.contentInsets.right - ((_numberOfColumns - 1) * self.componentsSpace)) / (CGFloat)_numberOfColumns;
    return viewWidth;
}

@end
