//
//  CKButtonViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-03.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKButtonViewController.h"
#import "CKResourceManager.h"

@interface CKButtonViewController ()

@end

@implementation CKButtonViewController

- (void)dealloc{
    [_customizeButtonBlock release];
    [_label release];
    [_imageName release];
    [super dealloc];
}

+ (instancetype)controllerWithLabel:(NSString*)label action:(void(^)(CKButtonViewController* controller))action{
    return [self controllerWithLabel:label imageName:nil action:action];
}

+ (instancetype)controllerWithLabel:(NSString*)label imageName:(NSString*)imageName action:(void(^)(CKButtonViewController* controller))action{
    CKButtonViewController* controller = [[[[self class]alloc]init]autorelease];
    controller.label = label;
    controller.imageName = imageName;
    if(action){
        controller.didSelectBlock = ^(CKReusableViewController* controller){
            action((CKButtonViewController*)controller);
        };
    }
    
    return controller;
}

- (void)postInit{
    [super postInit];
    self.flags = CKViewControllerFlagsNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setDefaultTextColor:[UIColor blackColor]];
    button.flexibleWidth = YES;
    button.name = @"Button";
    
    CKHorizontalBoxLayout* hbox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[button]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hbox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    __block CKButtonViewController* bself = self;
    
    if(self.label){ [self setupLabel]; }
    if(self.imageName){ [self setupImage]; }
    
    if(self.customizeButtonBlock){
        UIButton* Button = [self.view viewWithName:@"Button"];
        self.customizeButtonBlock(self,Button);
    }
    
    UIButton* button = [self.view viewWithName:@"Button"];
    [button bindEvent:UIControlEventTouchUpInside withBlock:^{
        [bself didSelect];
    }];
}

- (void)setupLabel{
    UIButton* Button = [self.view viewWithName:@"Button"];
    [Button setDefaultTitle:self.label];
}

- (void)setupImage{
    UIButton* Button = [self.view viewWithName:@"Button"];
    [Button setDefaultImage:[CKResourceManager imageNamed:self.imageName]];
}

- (void)setLabel:(NSString *)label{
    [_label release];
    _label = [label retain];
    
    if(self.state == CKViewControllerStateDidAppear){
        [self setupLabel];
    }
}

- (void)setImageName:(NSString *)imageName{
    [_imageName release];
    _imageName = [imageName retain];
    
    if(self.state == CKViewControllerStateDidAppear){
        [self setupImage];
    }
}

@end
