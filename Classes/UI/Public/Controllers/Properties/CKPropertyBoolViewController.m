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
    self.flags = CKViewControllerFlagsNone;
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    UILabel* PropertyNameLabel = [[[UILabel alloc]init]autorelease];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    PropertyNameLabel.marginRight = 10;
    
    UILabel* SubtitleLabel = [[[UILabel alloc]init]autorelease];
    SubtitleLabel.name = @"SubtitleLabel";
    SubtitleLabel.font = [UIFont systemFontOfSize:14];
    SubtitleLabel.textColor = [UIColor blackColor];
    SubtitleLabel.numberOfLines = 1;
    SubtitleLabel.marginRight = 10;
    SubtitleLabel.marginTop = 10;
    
    
    UISwitch* ValueSwitch = [[[UISwitch alloc]init]autorelease];
    ValueSwitch.name = @"ValueSwitch";
    
    CKVerticalBoxLayout* vBox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,SubtitleLabel]];
    
    CKHorizontalBoxLayout* hBox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vBox,[[[CKLayoutFlexibleSpace alloc]init]autorelease],ValueSwitch]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.view)
        return;
    
    [self.view beginBindingsContextWithScope:@"CKPropertyBoolViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContextWithScope:@"CKPropertyBoolViewController"];
}


- (void)setupBindings{
    __unsafe_unretained CKPropertyBoolViewController* bself = self;
    
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UILabel* SubtitleLabel = [self.view viewWithName:@"SubtitleLabel"];
    
    UISwitch* ValueSwitch = [self.view viewWithName:@"ValueSwitch"];
    
    [ValueSwitch bindEvent:UIControlEventValueChanged withBlock:^{
        [bself.property setValue:@(ValueSwitch.on)];
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        BOOL bo = [value boolValue];
        SubtitleLabel.text = bo ? bself.onSubtitleLabel : bself.offSubtitleLabel;
        SubtitleLabel.hidden = (SubtitleLabel.text == nil);
        
        if(ValueSwitch.on != bo){
            ValueSwitch.on = bo;
        }
    }];
}


@end
