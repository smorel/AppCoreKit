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
    [self setupSubViewControllers];
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

- (void)setupSubViewControllers{
    NSArray* viewControllers = @[
        //TODO : setup the sub View Controllers
    ];
    
    self.viewControllers = viewControllers;
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    //TODO : Setup Views and bindings
}

@end
