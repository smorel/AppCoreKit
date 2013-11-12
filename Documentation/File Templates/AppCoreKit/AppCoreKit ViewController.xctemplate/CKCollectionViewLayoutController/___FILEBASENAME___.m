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
    [self setupCollectionViewAndLayout];
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

- (void)setupCollectionViewAndLayout{
    
    //TODO : Setup your layout
    
    CKCollectionViewGridLayout* layout  = [[CKCollectionViewGridLayout alloc]init];
    layout.pages = @[
                             @[
                                 @[  @(.3333),@(.3333),@(.3333)   ],
                                 @[  @(.3333),@(.3333),@(.3333)   ],
                                 @[  @(.3333),@(.3333),@(.3333)   ]
                                 ]
                             ];
    layout.horizontalSpace = 0;
    layout.verticalSpace = 0;
    layout.orientation = CKCollectionViewLayoutOrientationVertical;
    layout.pagingEnabled = YES;
    
    __unsafe_unretained ___FILEBASENAMEASIDENTIFIER___* bself = self;
    
    CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
    [factory addItemForObjectOfClass:[NSObject class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
        CKCollectionCellContentViewController* content = [bself contentViewControllerForObject:object];
        CKCollectionContentCellController* cell = [[CKCollectionContentCellController alloc]initWithContentViewController:content];
        
        CKCallback* selection = [CKCallback callbackWithBlock:^id(id value) {
            [bself didSelectObject:object atIndexPath:indexPath];
            return nil;
        }];
        
        [cell setSelectionCallback:selection];
        return cell;
    }];
    
    //TODO : setup your model collection represented by the collection view
    
    CKCollection* collection = nil;
    
    [self setupWithLayout:layout collection:collection factory:factory];
}

- (CKCollectionCellContentViewController*)contentViewControllerForObject:(id)object{
    
    //TODO : Setup the content view controller representing the specified object
    
    return [[CKCollectionCellContentViewController alloc]init];
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    
    //TODO : Handle the selection for the specified object
    
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    //TODO : Setup Views and bindings
}

@end
