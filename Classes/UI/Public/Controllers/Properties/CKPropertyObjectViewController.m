//
//  CKPropertyObjectViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyObjectViewController.h"
#import "CKStandardContentViewController.h"

@implementation CKPropertyObjectViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CKStandardContentViewController* controller = [[[CKStandardContentViewController alloc]init]autorelease];
    controller.name = @"ContentViewController";
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[controller]];
    
    //   self.accessoryType = CKAccessoryDisclosureIndicator;
}

- (void)setupBindings{
    CKStandardContentViewController* controller = (CKStandardContentViewController*)[self.view layoutWithName:@"ContentViewController"];
    controller.title = self.propertyNameLabel;
    controller.subtitle = [self.property.value description];
    [controller.view invalidateLayout];
}

- (void)didSelect{
    [super didSelect];
    
    //TODO
}

@end
