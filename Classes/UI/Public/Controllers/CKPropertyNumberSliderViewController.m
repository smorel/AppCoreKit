//
//  CKPropertyNumberSliderViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-03.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyNumberSliderViewController.h"
#import "CKLocalization.h"
#import "CKReusableViewController+ResponderChain.h"
#import "CKPropertyNumberViewController.h"
#import "NSValueTransformer+Additions.h"
#import "NSValueTransformer+CGTypes.h"

@interface CKPropertyNumberSliderViewController ()

@end

@implementation CKPropertyNumberSliderViewController

- (void)dealloc{
    [_textFormat release];
    [super dealloc];
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];

    self.flags = CKViewControllerFlagsNone;
    
    return self;
}

- (void)postInit{
    [super postInit];
    self.textFormat = @"%g";
    self.maximumValue = -1;
    self.minimumValue = -1;
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
    PropertyNameLabel.marginBottom = 10;
    
    UISlider* ValueSlider = [[[UISlider alloc]init]autorelease];
    ValueSlider.name = @"ValueSlider";
    
    UILabel* ValueLabel = [[[UILabel alloc]init]autorelease];
    ValueLabel.name = @"ValueLabel";
    ValueLabel.font = [UIFont systemFontOfSize:14];
    ValueLabel.numberOfLines = 0;
    ValueLabel.marginLeft = 10;
    
    CKHorizontalBoxLayout* hBox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[ValueSlider,ValueLabel]];
    
    CKVerticalBoxLayout* vBox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vBox.horizontalAlignment = CKLayoutHorizontalAlignmentLeft;
    vBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,hBox]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vBox]];
}


#pragma mark Setup MVC and bindings

- (void)setupBindings{
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UISlider* ValueSlider = [self.view viewWithName:@"ValueSlider"];
    if(self.maximumValue > 0){
        ValueSlider.maximumValue = self.maximumValue;
    }
    if(self.minimumValue > 0){
        ValueSlider.minimumValue = self.minimumValue;
    }
    
    __block CKPropertyNumberSliderViewController* bself = self;
    
    [self bind:@"readOnly" executeBlockImmediatly:YES withBlock:^(id value) {
        ValueSlider.userInteractionEnabled = !bself.readOnly;
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
        NSNumber* v = [NSValueTransformer transform:value toClass:[NSNumber class]];
        [bself setupLabel];
        
        if(ValueSlider.value != [v floatValue]){
            ValueSlider.value = [v floatValue];
        }
    }];
    
    [ValueSlider bindEvent:UIControlEventValueChanged withBlock:^(){
        [NSValueTransformer transform:[NSNumber numberWithFloat:ValueSlider.value] inProperty:bself.property];
    }];
}

- (void)setupLabel{
    NSNumber* value = [NSValueTransformer transformProperty:self.property toClass:[NSNumber class]];
    NSString* str = [NSString stringWithFormat:self.textFormat,[value floatValue]];
    
    UILabel* ValueLabel = [self.view viewWithName:@"ValueLabel"];
    ValueLabel.text = str;
}

- (void)setTextFormat:(NSString*)textFormat{
    [_textFormat release];
    _textFormat = [textFormat retain];
    
    if(self.state == CKViewControllerStateDidAppear){
        [self setupLabel];
    }
}

- (void)setMaximumValue:(CGFloat)value{
    _maximumValue = value;
    
    if(self.state == CKViewControllerStateDidAppear){
        UISlider* ValueSlider = [self.view viewWithName:@"ValueSlider"];
        ValueSlider.maximumValue = value;
    }
}

- (void)setMinimumValue:(CGFloat)value{
    _minimumValue = value;
    
    if(self.state == CKViewControllerStateDidAppear){
        UISlider* ValueSlider = [self.view viewWithName:@"ValueSlider"];
        ValueSlider.minimumValue = value;
    }
}

@end
