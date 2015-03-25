//
//  CKGridCollectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKGridCollectionViewController.h"
#import "CKGridTableViewCellController.h"
#import "CKArrayCollection.h"
#import "CKDebug.h"

@interface CKCollectionViewControllerOld()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;
@property (nonatomic, retain) NSMutableArray* sectionsToControllers;

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end


@interface CKTableViewControllerOld ()
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL tableViewHasBeenReloaded;
@end

@interface CKCollectionViewControllerOld(CKCollectionCellControllerManagement)
- (CKCollectionCellController*)createsControllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end


@interface CKTableCollectionViewController ()
@property (nonatomic, retain) NSIndexPath* indexPathToReachAfterRotation;
- (void)updateGridArray;
@end


@interface CKGridCollectionViewController ()
@property(nonatomic,retain) NSMutableArray* subControllers;
@property(nonatomic,retain) CKArrayCollection* objectsAsGrid;
@property(nonatomic,retain) CKCollection* linearCollection;
@property(nonatomic,retain) CKCollectionCellControllerFactory* subControllersFactory;
@property(nonatomic,retain) CKCollectionController* linearCollectionController;
@property (nonatomic, retain) NSIndexPath *gridItemSelectedIndexPath;
@end

@implementation CKGridCollectionViewController
@synthesize size = _size;
@synthesize subControllers = _subControllers;
@synthesize linearCollection = _linearCollection;
@synthesize subControllersFactory = _subControllersFactory;
@synthesize linearCollectionController = _linearCollectionController;
@synthesize objectsAsGrid = _objectsAsGrid;

- (void)postInit{
    [super postInit];
    _size = CGSizeMake(5,2);
}

- (void)dealloc{
    [_objectsAsGrid release];
    [_subControllers release];
    [_linearCollection release];
    [_subControllersFactory release];
    [_linearCollectionController release];
    [super dealloc];
}

- (void)setupWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory{
    [_linearCollectionController setDelegate:nil];
    self.linearCollection = collection;
    self.subControllersFactory = factory;
    self.subControllers = [NSMutableArray array];
    
    int i =0;
    for(id object in [collection allObjects]){
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CKCollectionCellController* subcontroller = [self.subControllersFactory controllerForObject:object  atIndexPath:indexPath collectionViewController:self];
        [self.subControllers insertObject:subcontroller atIndex:indexPath.row];
        
        [subcontroller performSelector:@selector(setContainerController:) withObject:self];
        [subcontroller performSelector:@selector(setValue:) withObject:object];
        [subcontroller performSelector:@selector(setIndexPath:) withObject:indexPath];
        
        ++i;
    }
    
    self.linearCollectionController = [CKCollectionController controllerWithCollection:collection];
    _linearCollectionController.delegate = self;
    
    //OBSERVE collection & keeps factory to create/remove controllers in _subControllers
    self.objectsAsGrid = [CKArrayCollection collection];
    
    [super setupWithCollection:self.objectsAsGrid factory:factory];
    [self updateGridArray];
}

- (void)rebuildGridArray{
    NSInteger columnCount = 0;
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            columnCount = self.size.width;
            break;
        }
        case CKTableViewOrientationPortrait:{
            columnCount = self.size.height;
            break;
        }
    }
    
    CKCollection* theCollection = [(CKCollectionController*)self.objectController collection];
    [theCollection removeAllObjects];
    
    NSMutableArray* arrayOfArray = [NSMutableArray array];
    
    int column =0, row =0;
    NSMutableArray* currentArray = nil;
    for(id object in self.linearCollection){
        if(column == 0){
            currentArray = [NSMutableArray array];
        }
        
        [currentArray addObject:object];
        
        ++column;
        
        if(column >= columnCount){
            column = 0;
            [arrayOfArray addObject:currentArray];
            
            ++row;
        }
    }
    
    if([currentArray count] > 0 && [currentArray count] < columnCount){
        [arrayOfArray addObject:currentArray];
    }
    
    if([arrayOfArray count] > 0 ){
        [theCollection addObjectsFromArray:arrayOfArray];
    }
}

- (void)updateGridArray{
    NSInteger columnCount = 0;
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            columnCount = self.size.width;
            break;
        }
        case CKTableViewOrientationPortrait:{
            columnCount = self.size.height;
            break;
        }
    }
    
  //  [self.tableView beginUpdates];
    
    CKCollection* theCollection = [(CKCollectionController*)self.objectController collection];
    
    CGFloat floatingNumberOfRows = (CGFloat)[self.linearCollection count] / (CGFloat)columnCount;
    NSInteger numberOfRows = ceilf(floatingNumberOfRows);
    if(numberOfRows < [theCollection count]){
        [theCollection removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(numberOfRows, [theCollection count] - numberOfRows)]];
    }
    
    int column =0, row =0;
    NSMutableArray* currentArray = nil;
    for(id object in self.linearCollection){
        if(column == 0){
            currentArray = [NSMutableArray array];
        }
        
        [currentArray addObject:object];
        
        ++column;
        
        if(column >= columnCount){
            column = 0;
            if(row < [theCollection count]){
                [theCollection replaceObjectAtIndex:row byObject:currentArray];
            }else{
                [theCollection addObject:currentArray];
            }
                
            ++row;
        }
    }
    
    if([currentArray count] > 0 && [currentArray count] < columnCount){
        if([theCollection count] > row){
            [theCollection replaceObjectAtIndex:row byObject:currentArray];
        }else{
            [theCollection addObject:currentArray];
        }
    }
    
 //   [self.tableView endUpdates];
}

- (void)setSize:(CGSize)s{
    if(!CGSizeEqualToSize(_size, s)){
        NSInteger firstVisibleIndex = [self.indexPathToReachAfterRotation row];
        CGSize oldSize = _size;
        _size = s;
        
        [self rebuildGridArray];
        
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
        
        NSInteger oldIndex = 0;
        switch(self.orientation){
            case CKTableViewOrientationLandscape:{
                oldIndex = (oldSize.width * firstVisibleIndex) + 0;
                break;
            }
            case CKTableViewOrientationPortrait:{
                oldIndex = (oldSize.height * firstVisibleIndex) + 0;
                break;
            }
        }
        
        
        NSInteger newIndex = 0;
        
        switch(self.orientation){
            case CKTableViewOrientationLandscape:{
                newIndex = oldIndex /  _size.width;
                break;
            }
            case CKTableViewOrientationPortrait:{
                newIndex = oldIndex / _size.height;
                break;
            }
        }
        
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
        self.indexPathToReachAfterRotation = newIndexPath;
        
        
        if(self.state != CKViewControllerStateDidAppear){
            self.tableViewHasBeenReloaded = NO;
        }else{
            [self scrollToRowAtIndexPath:newIndexPath animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            return floorf((tableView.bounds.size.width - (self.tableViewInsets.left + self.tableViewInsets.right)) / _size.height);
            break;
        }
        case CKTableViewOrientationPortrait:{
            return floorf((tableView.bounds.size.height - (self.tableViewInsets.top + self.tableViewInsets.bottom)) / _size.width);
            break;
        }
    }
    return 0;
}

- (CKCollectionCellController*)createsControllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    CKAssert([object isKindOfClass:[NSArray class]],@"invalid object class");
              
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
    return controller;
}

//Sub controllers management

- (void)objectControllerDidBeginUpdating:(id)controller{
    if(controller == self.linearCollectionController){
        return;
    }
    [super objectControllerDidBeginUpdating:controller];
}

- (void)objectControllerDidEndUpdating:(id)controller{
    if(controller == self.linearCollectionController){
        return;
    }
    [super objectControllerDidEndUpdating:controller];
}

- (void)objectControllerReloadData:(id)controller{
    if(controller == self.linearCollectionController){
        CKAssert(NO,@"NOT IMPLEMENTED");
        
        [self updateGridArray];
        return;
    }
    
    [super objectControllerReloadData:controller];
}
 
- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(controller == self.linearCollectionController){
        
        if(self.state == CKViewControllerStateDidAppear){
       //     [self.tableView beginUpdates];
        }
        
        CKCollection* theCollection = [(CKCollectionController*)self.objectController collection];
        
        NSInteger columnCount = 0;
        switch(self.orientation){
            case CKTableViewOrientationLandscape:{
                columnCount = self.size.width;
                break;
            }
            case CKTableViewOrientationPortrait:{
                columnCount = self.size.height;
                break;
            }
        }

        
        int i =0;
        NSMutableArray* currentArray = [NSMutableArray array];
        NSInteger gridRow = 0;
        
        for(id object in objects){
            NSIndexPath* indexPath = [indexPaths objectAtIndex:i];
            CKCollectionCellController* subcontroller = [self.subControllersFactory controllerForObject:object  atIndexPath:indexPath collectionViewController:self];
            [self.subControllers insertObject:subcontroller atIndex:indexPath.row];
            
            [subcontroller performSelector:@selector(setContainerController:) withObject:self];
            [subcontroller performSelector:@selector(setValue:) withObject:object];
            [subcontroller performSelector:@selector(setIndexPath:) withObject:indexPath];
            
                       
            NSInteger gridColumn = (indexPath.row % columnCount);
            gridRow = (indexPath.row - gridColumn) / columnCount;
            
            if([theCollection count] > gridRow){
                currentArray = [theCollection objectAtIndex:gridRow];
            }
            
            if([currentArray count] > gridColumn){
                [currentArray replaceObjectAtIndex:gridColumn withObject:object];
            }else{
                [currentArray addObject:object];
            }
            
            if(gridColumn == columnCount - 1){
                if([theCollection count] > gridRow){
                    [theCollection replaceObjectAtIndex:gridRow byObject:currentArray];
                }else{
                    [theCollection addObject:currentArray];
                }
                currentArray = [NSMutableArray array];
            }

            ++i;
        }
        
        if([currentArray count] > 0 && [currentArray count] < columnCount){
            if([theCollection count] > gridRow){
                [theCollection replaceObjectAtIndex:gridRow byObject:currentArray];
            }else{
                [theCollection addObject:currentArray];
            }
        }
        
        if(self.state == CKViewControllerStateDidAppear){
        //    [self.tableView endUpdates];
        }
        return;
    }
    
    [super objectController:controller insertObjects:objects atIndexPaths:indexPaths];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(controller == self.linearCollectionController){
   //     CKAssert(NO,@"NOT IMPLEMENTED");
        
        NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
        for(NSIndexPath* indexPath in indexPaths){
            [indexSet addIndex:indexPath.row];
        }
        
        [self.subControllers removeObjectsAtIndexes:indexSet];
        [self updateGridArray];
        return;
    }
    
    [super objectController:controller removeObjects:objects atIndexPaths:indexPaths];
}

- (CKCollectionCellController*)subControllerForRow:(NSInteger)row column:(NSInteger)column{
    NSInteger index = 0;
    switch(self.orientation){
        case CKTableViewOrientationLandscape:{
            index = (self.size.width * row) + column;
            break;
        }
        case CKTableViewOrientationPortrait:{
            index = (self.size.height * row) + column;
            break;
        }
    }
    
    return [self.subControllers objectAtIndex:index];
}

- (void)fetchObjectsInRange:(NSRange)range forSection:(NSInteger)section{
    NSInteger height = 0;
    switch(self.orientation){
        case CKTableViewOrientationPortrait:{
            height = _size.height;
            break;
        }
        case CKTableViewOrientationLandscape:{
            height = _size.width;
            break;
        }
    }

     [self.linearCollection fetchRange:NSMakeRange(range.location * height, range.length * height)];
}

@end
