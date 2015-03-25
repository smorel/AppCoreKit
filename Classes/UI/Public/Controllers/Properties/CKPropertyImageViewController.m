//
//  CKPropertyImageViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyImageViewController.h"

@implementation CKPropertyImageViewController

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
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
    
    UIImageView* ImageView = [[[UIImageView alloc]init]autorelease];
    ImageView.name = @"ImageView";
    ImageView.marginTop = 10;
    
    CKVerticalBoxLayout* vbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,ImageView]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vbox]];
}

- (void)setupBindings{
    
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UIImageView* ImageView = [self.view viewWithName:@"ImageView"];
    ImageView.image = self.property.value;
}

@end
