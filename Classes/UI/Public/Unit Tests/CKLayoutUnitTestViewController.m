//
//  CKLayoutUnitTestViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-05.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKLayoutUnitTestViewController.h"
#import "CKPropertyTextField.h"
#import "CKPropertyTextView.h"
#import "CKPropertySwitch.h"

@interface CKLayoutUnitTestViewController ()
@property(nonatomic,retain) NSString* text;
@property(nonatomic,assign) BOOL bo;
@end

@implementation CKLayoutUnitTestViewController

- (void)postInit{
    [super postInit];
    self.text = @"HEY!";
    [self setupTableView];
}

- (void)setupTableView{
    CKSection* section = [CKSection sectionWithControllers:@[[self testViewController], [self propertyTextFieldController], [self propertyTextViewController], [self propertySwitchController]]];
    
    [self addSections:@[section] animated:NO];
    
    /*[self beginBindingsContext];
    [self bindPropertyChangeWithBlock:^(NSString *propertyName, id value) {
        NSLog(@"Property Changed: %@ - %@",propertyName,value);
    }];
    [self endBindingsContext];
     */
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

- (CKReusableViewController*)propertyTextFieldController{
    CKReusableViewController* controller = [[[CKReusableViewController alloc]init]autorelease];
    controller.viewDidLoadBlock = ^(UIViewController* controller){
        controller.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
        
        CKPropertyTextField* propertyView = [[[CKPropertyTextField alloc]init]autorelease];
        propertyView.name = @"textField";
        
        controller.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[propertyView]];
    };
    
    controller.viewWillAppearBlock = ^(UIViewController* controller, BOOL animated){
        CKPropertyTextField* propertyView = [controller.view viewWithName:@"propertyView"];
        propertyView.property = [CKProperty propertyWithObject:self keyPath:@"text"];
    };
    
    return controller;
}

- (CKReusableViewController*)propertyTextViewController{
    CKReusableViewController* controller = [[[CKReusableViewController alloc]init]autorelease];
    controller.viewDidLoadBlock = ^(UIViewController* controller){
        controller.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
        
        CKPropertyTextView* propertyView = [[[CKPropertyTextView alloc]init]autorelease];
        propertyView.name = @"propertyView";
        
        controller.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[propertyView]];
    };
    
    controller.viewWillAppearBlock = ^(UIViewController* controller, BOOL animated){
        CKPropertyTextView* propertyView = [controller.view viewWithName:@"propertyView"];
        propertyView.property = [CKProperty propertyWithObject:self keyPath:@"text"];
    };
    
    return controller;
}

- (CKReusableViewController*)propertySwitchController{
    CKReusableViewController* controller = [[[CKReusableViewController alloc]init]autorelease];
    controller.viewDidLoadBlock = ^(UIViewController* controller){
        controller.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
        
        CKPropertySwitch* propertyView = [[[CKPropertySwitch alloc]init]autorelease];
        propertyView.name = @"propertyView";
        
        controller.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[propertyView]];
    };
    
    controller.viewWillAppearBlock = ^(UIViewController* controller, BOOL animated){
        CKPropertySwitch* propertyView = [controller.view viewWithName:@"propertyView"];
        propertyView.property = [CKProperty propertyWithObject:self keyPath:@"bo"];
    };
    
    return controller;
}

@end
