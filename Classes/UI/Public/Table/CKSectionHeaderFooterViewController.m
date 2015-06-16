//
//  CKSectionHeaderFooterViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-19.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionHeaderFooterViewController.h"

@implementation CKSectionHeaderFooterViewController

+ (instancetype)controllerWithType:(CKSectionViewControllerType)type text:(NSString*)text{
    CKSectionHeaderFooterViewController* controller = [[[[self class]alloc]init]autorelease];
    controller.type = type;
    controller.text = text;
    return controller;
}

- (void)postInit{
    [super postInit];
    
    self.flags = CKViewControllerFlagsNone;
}

- (void)dealloc{
    [_text release];
    [super dealloc];
}

- (void)typeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKSectionViewControllerType",
                                                 CKSectionViewControllerTypeHeader,
                                                 CKSectionViewControllerTypeFooter);
    [attributes.enumDescriptor addValue:@"CKSectionViewControllerTypeHeader" label:@"header"];
    [attributes.enumDescriptor addValue:@"CKSectionViewControllerTypeFooter" label:@"footer"];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UILabel* label = [[[UILabel alloc]init]autorelease];
    label.name = @"TextLabel";
    label.font = (self.type == CKSectionViewControllerTypeHeader) ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:14];
    label.numberOfLines = (self.type == CKSectionViewControllerTypeHeader) ? 1 : 0;
    label.textAlignment = (self.type == CKSectionViewControllerTypeHeader) ? UITextAlignmentLeft : UITextAlignmentCenter;
    label.flexibleWidth = (self.type == CKSectionViewControllerTypeHeader) ? NO : YES;
    
    CKHorizontalBoxLayout* hbox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[label]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hbox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UILabel* label = [self.view viewWithName:@"TextLabel"];
    label.text = self.text;
}

@end
