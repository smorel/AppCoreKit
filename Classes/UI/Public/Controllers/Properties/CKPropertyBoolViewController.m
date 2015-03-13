//
//  CKPropertyBoolViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyBoolViewController.h"

@interface CKPropertyBoolViewController ()

@end

@implementation CKPropertyBoolViewController

- (void)dealloc{
    [_propertyNameLabel release];
    [super dealloc];
}

#pragma mark ViewController Life Cycle

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    
    NSAssert([property isBool],@"CKPropertyBoolViewController aims to work with BOOL properties only.");
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    self.propertyNameLabel = _(property.name);
    
    return self;
}

- (void)postInit{
    self.collectionCellController.flags = CKItemViewFlagNone;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UILabel* PropertyNameLabel = [[UILabel alloc]init];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    PropertyNameLabel.marginRight = 10;
    
    UISwitch* ValueSwitch = [[UISwitch alloc]init];
    ValueSwitch.name = @"ValueSwitch";
    
    CKHorizontalBoxLayout* hBox = [[CKHorizontalBoxLayout alloc]init];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,[[[CKLayoutFlexibleSpace alloc]init]autorelease],ValueSwitch]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.view)
        return;
    
    [self.view beginBindingsContextByRemovingPreviousBindings];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContext];
}


- (void)setupBindings{
    __unsafe_unretained CKPropertyBoolViewController* bself = self;
    
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UISwitch* ValueSwitch = [self.view viewWithName:@"ValueSwitch"];
    
    [ValueSwitch bindEvent:UIControlEventValueChanged withBlock:^{
        [bself.property setValue:@(ValueSwitch.on)];
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        BOOL bo = [value boolValue];
        if(ValueSwitch.on != bo){
            ValueSwitch.on = bo;
        }
    }];
}


@end
