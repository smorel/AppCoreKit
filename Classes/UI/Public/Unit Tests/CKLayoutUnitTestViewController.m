//
//  CKLayoutUnitTestViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-05.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKLayoutUnitTestViewController.h"

@interface CKLayoutUnitTestViewController ()

@end

@implementation CKLayoutUnitTestViewController

- (void)postInit{
    [super postInit];
    [self setupTableView];
}

- (void)setupTableView{
    CKReusableViewController* controller = [self testViewController];
    CKSection* section = [CKSection sectionWithControllers:@[controller]];
    
    [self addSections:@[section] animated:NO];
}

- (CKReusableViewController*)testViewController{
    //This controller test how robust the layout system is with lots of flexible views and flexi-space trying to compute a preferred size with an infinite Height constraint
    
    CKReusableViewController* controller = [[[CKReusableViewController alloc]init]autorelease];
    controller.viewDidLoadBlock = ^(UIViewController* controller){
        controller.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
        
        UILabel* label = [[[UILabel alloc]init]autorelease];
        label.textColor = [UIColor blackColor];
        label.text = @"HEY!";
        label.layer.borderColor = [UIColor redColor].CGColor;
        label.layer.borderWidth = 2;
        label.flexibleWidth = YES;
        
        CKVerticalBoxLayout* vBox = [[[CKVerticalBoxLayout alloc]init]autorelease];
        vBox.flexibleSize = YES;
        vBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[ [[[CKLayoutFlexibleSpace alloc]init]autorelease],label,[[[CKLayoutFlexibleSpace alloc]init]autorelease]]];
        
        UIView* view = [[[UIView alloc]init]autorelease];
        view.backgroundColor = [UIColor blueColor];
        view.fixedSize = CGSizeMake(50,50);
        view.marginRight = 10;
        
        CKHorizontalBoxLayout* hBox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
        hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[view, vBox]];
        
        controller.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox]];
    };
    return controller;
}

@end
