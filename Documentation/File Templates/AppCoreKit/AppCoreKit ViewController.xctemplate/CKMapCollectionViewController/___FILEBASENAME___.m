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
    [self setupMap];
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

#pragma mark Initializing View Controller

- (void)setupMap{
    __unsafe_unretained ___FILEBASENAMEASIDENTIFIER___ *bself = self;
    
    //TODO : setup the collection represented by the map
    CKCollection* collection = nil;
    
    CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
    [factory addItemForObjectOfClass:[NSObject class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
        return [bself mapAnnotationControllerForObject:object];
    }];
    
    [self setupWithCollection:collection factory:factory];
}

- (CKMapAnnotationController*)mapAnnotationControllerForObject:(id)object{
    __unsafe_unretained ___FILEBASENAMEASIDENTIFIER___ *bself = self;
    
    CKMapAnnotationController* controller = [CKMapAnnotationController annotationController];
    controller.value = object;
    controller.style = CKMapAnnotationCustom;
    
    //TODO : Customize the map annotation controller here
    
    [controller setSetupBlock:^(CKMapAnnotationController *controller, MKAnnotationView *view) {
        CKAnnotationView* annotationView = (CKAnnotationView*)view;
        
        //TODO : Customize the map annotation view here
        
        annotationView.canShowCallout = YES;
        annotationView.calloutViewControllerCreationBlock = ^(CKMapAnnotationController* annotationController, CKAnnotationView* annotationView) {
            return [bself calloutViewControllerForObject:annotationController.value];
        };
    }];
    
    return controller;
}

- (UIViewController*)calloutViewControllerForObject:(id)object{
    //TODO : Setup the map annotation callout view controller here
    
    CKViewController* controller = [CKViewController controller];
    controller.contentSizeForViewInPopover = CGSizeMake(300,80);
    return controller;
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    //TODO : Setup Views and bindings
}

@end
