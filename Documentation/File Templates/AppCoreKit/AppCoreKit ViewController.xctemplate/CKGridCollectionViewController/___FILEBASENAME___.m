//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

@interface ___FILEBASENAMEASIDENTIFIER___ ()

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

#pragma mark ViewController Life Cycle

- (void)postInit{
    [super postInit];
    [self setupGrid];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [self setupBindings];
    [self endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self clearBindingsContext];
}

#pragma mark Initializing Collection View Controller

- (void)setupGrid{
    
    __unsafe_unretained ___FILEBASENAMEASIDENTIFIER___* bself = self;
    
    CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
    [factory addItemForObjectOfClass:[NSObject class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
        return [bself cellControllerForObject:object];
    }];
    
    //TODO : setup your model collection represented by the collection view
    
    CKCollection* collection = nil;
    
    [self setupWithCollection:collection factory:factory];
}

- (CKTableViewCellController*)cellControllerForObject:(id)object{
    
    //TODO : Setup the cell controller representing the specified object
    
    return [CKTableViewCellController cellController];
}


#pragma mark Setup MVC and bindings

- (void)setupBindings{
    //TODO : Setup Views and bindings
}

@end
