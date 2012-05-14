//
//  CKBindedGridViewController.m
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKBindedGridViewController.h"
#import "CKGridTableViewCellController.h"
#import "CKGridCollection.h"


@interface CKItemViewContainerController(CKItemViewControllerManagement)
- (CKItemViewController*)createsControllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end


@interface CKBindedTableViewController ()
@property (nonatomic, retain) NSIndexPath* indexPathToReachAfterRotation;
@end

@interface CKBindedGridViewController ()

@end

@implementation CKBindedGridViewController
@synthesize size = _size;

- (void)postInit{
    [super postInit];
    _size = CGSizeMake(5,2);
}

- (void)setupWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory{
    CKGridCollection* gridCollection = [[[CKGridCollection alloc]initWithCollection:collection size:_size ]autorelease];
    [super setupWithCollection:gridCollection factory:factory];
}

/*
- (void)setObjectController:(id)objectController{
    [super setObjectController:objectController];
    
    NSAssert([self.objectController isKindOfClass:[CKCollectionController class]],@"Invalid ObjectController Class");
    CKCollectionController* collectionController = (CKCollectionController*)self.objectController;
    collectionController.animateInsertionsOnReload = NO;
}
 */

- (CKGridCollection*)gridCollection{
    NSAssert([self.objectController isKindOfClass:[CKCollectionController class]],@"Invalid ObjectController Class");
    CKCollectionController* collectionController = (CKCollectionController*)self.objectController;
    NSAssert([collectionController.collection isKindOfClass:[CKGridCollection class]],@"Invalid Collection Class");
    return (CKGridCollection*)collectionController.collection;
}

- (void)setSize:(CGSize)s{
    NSArray* indexPaths = [self visibleIndexPaths];
    NSInteger firstVisibleIndex = ([indexPaths count] > 0) ? [[indexPaths objectAtIndex:0]row] : 0;
    CGSize oldSize = _size;
    _size = s;
    
    switch(self.orientation){
        case CKTableViewOrientationPortrait:{
            [[self gridCollection]setSize:_size];
            break;
        }
        case CKTableViewOrientationLandscape:{
            [[self gridCollection]setSize:CGSizeMake(_size.height,_size.width)];
            break;
        }
    }
    
    for(int i = 0; i < [self numberOfObjectsForSection:0]; ++i){
        CKGridTableViewCellController* controller = (CKGridTableViewCellController*)[self controllerAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        switch(self.orientation){
            case CKTableViewOrientationLandscape:{
                controller.numberOfColumns = _size.width;
                break;
            }
            case CKTableViewOrientationPortrait:{
                controller.numberOfColumns = _size.height;
                break;
            }
        }
    }
    
    NSInteger multiply = 0;
    NSInteger oldmultiply = 0;
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            multiply = _size.width;
            oldmultiply = oldSize.width;
            break;
        }
        case CKTableViewOrientationPortrait:{
            multiply = _size.height;
            oldmultiply = oldSize.height;
            break;
        }
    }
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:firstVisibleIndex * oldmultiply / multiply inSection:0];
    self.indexPathToReachAfterRotation = newIndexPath;
    [self scrollToRowAtIndexPath:newIndexPath animated:(self.state == CKUIViewControllerStateDidAppear)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            return (tableView.bounds.size.width - (self.tableViewInsets.left + self.tableViewInsets.right)) / _size.height;
            break;
        }
        case CKTableViewOrientationPortrait:{
            return (tableView.bounds.size.height - (self.tableViewInsets.top + self.tableViewInsets.bottom)) / _size.width;
            break;
        }
    }
    return 0;
}

- (CKItemViewController*)createsControllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    NSAssert([object isKindOfClass:[NSArray class]],@"invalid object class");
              
    CKGridTableViewCellController* controller = [CKGridTableViewCellController cellController];
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            controller.numberOfColumns = _size.width;
            break;
        }
        case CKTableViewOrientationPortrait:{
            controller.numberOfColumns = _size.height;
            break;
        }
    }
    controller.controllerFactory = _controllerFactory;
    return controller;
}

@end
