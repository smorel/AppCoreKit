//
//  CKBlurModalDebugViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/26/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKBlurModalDebugViewController.h"
#import "CKBlurModalViewController.h"
#import "CKObject.h"
#import "NSObject+Bindings.h"
#import "UIView+Name.h"

@interface CRBlurAttributes : CKObject
@property(nonatomic,assign) CGFloat radius;
@property(nonatomic,assign) NSTimeInterval duration;
@property(nonatomic,assign) CGFloat scale;
@property(nonatomic,assign) CGFloat red;
@property(nonatomic,assign) CGFloat green;
@property(nonatomic,assign) CGFloat blue;
@property(nonatomic,assign) CGFloat alpha;
@property(nonatomic,assign) CGFloat saturationDelta;
@end


@implementation CRBlurAttributes

- (void)postInit{
    self.duration = .3;
    self.radius = 2.0;
    self.saturationDelta = 1;
    self.red = self.green = self.blue = 0;
    self.alpha = 0.5f;
    self.scale = 0.9f;
    
    [super postInit];
}


@end


@interface CKBlurModalDebugViewController ()
@end

@implementation CKBlurModalDebugViewController

#pragma mark ViewController Life Cycle

- (id)initWithBlurModalViewController:(CKBlurModalViewController*)blurModalViewController{
    self = [super init];
    self.blurModalViewController = blurModalViewController;
    return self;
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

- (void)setBlurModalViewController:(CKBlurModalViewController *)blurModalViewController{
    _blurModalViewController = blurModalViewController;
    if(self.state == CKViewControllerStateDidAppear){
        [self beginBindingsContextByRemovingPreviousBindings];
        [self setupBindings];
        [self endBindingsContext];
    }
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    __block CKBlurModalDebugViewController* bself = self;
    
    UIButton* DimissButton = [self.view viewWithName:@"DimissButton"];
    [DimissButton bindEvent:UIControlEventTouchUpInside withBlock:^{
        [bself.blurModalViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    
    [self setupSlider:@"radius" ];
    [self setupSlider:@"scale" ];
    [self setupSlider:@"duration" ];
    [self setupSlider:@"red" ];
    [self setupSlider:@"green" ];
    [self setupSlider:@"blue" ];
    [self setupSlider:@"alpha" ];
    [self setupSlider:@"saturationDelta" ];
    
    UISegmentedControl* StyleSegmentedControl = [self.view viewWithName:@"StyleSegmentedControl"];
    [StyleSegmentedControl removeAllSegments];
    
    [StyleSegmentedControl insertSegmentWithTitle:@"Light" atIndex:0 animated:NO];
    [StyleSegmentedControl insertSegmentWithTitle:@"Dark" atIndex:1 animated:NO];
    StyleSegmentedControl.tintColor = [UIColor redColor];
    
    CRBlurAttributes* blur = [CRBlurAttributes sharedInstance];
    [blur bind:@"radius" withBlock:^(id value) {
        bself.blurModalViewController.blurRadius = [blur radius];
    }];
    
    [blur bind:@"scale" withBlock:^(id value) {
        bself.blurModalViewController.backgroundScale = [blur scale];
    }];
    
    [blur bind:@"duration" withBlock:^(id value) {
        bself.blurModalViewController.animationDuration = [blur duration];
    }];
    
    [blur bind:@"red" withBlock:^(id value) {
        bself.blurModalViewController.blurTintColor = [UIColor colorWithRed:[blur red] green:[blur green] blue:[blur blue] alpha:[blur alpha]];
    }];
    [blur bind:@"green" withBlock:^(id value) {
        bself.blurModalViewController.blurTintColor = [UIColor colorWithRed:[blur red] green:[blur green] blue:[blur blue] alpha:[blur alpha]];
    }];
    [blur bind:@"blue" withBlock:^(id value) {
        bself.blurModalViewController.blurTintColor = [UIColor colorWithRed:[blur red] green:[blur green] blue:[blur blue] alpha:[blur alpha]];
    }];
    [blur bind:@"alpha" withBlock:^(id value) {
        bself.blurModalViewController.blurTintColor = [UIColor colorWithRed:[blur red] green:[blur green] blue:[blur blue] alpha:[blur alpha]];
    }];
    
    [blur bind:@"saturationDelta" withBlock:^(id value) {
        bself.blurModalViewController.saturationDelta = [blur saturationDelta];
    }];

}

- (void)setupSlider:(NSString*)name{
    
    UISlider* slider = [self.view viewWithName:[NSString stringWithFormat:@"%@Slider",name]];
    UILabel* label = [self.view viewWithName:[NSString stringWithFormat:@"%@Label",name]];
    UILabel* titleLabel = [self.view viewWithName:[NSString stringWithFormat:@"%@:",name]];
    
    UISegmentedControl* StyleSegmentedControl = [self.view viewWithName:@"StyleSegmentedControl"];
    [StyleSegmentedControl bindEvent:UIControlEventValueChanged withBlock:^{
        titleLabel.textColor = label.textColor = StyleSegmentedControl.selectedSegmentIndex == 0 ? [UIColor whiteColor] : [UIColor darkGrayColor];
    }];
    
    [[CRBlurAttributes sharedInstance]bind:name executeBlockImmediatly:YES withBlock:^(id value) {
        if([value floatValue] != slider.value){
            slider.value = [value floatValue];
        }
        
        CKClassPropertyDescriptor* descriptor = [NSObject propertyDescriptorForClass:[CRBlurAttributes class] key:name];
        CKPropertyExtendedAttributes* attributes = [descriptor extendedAttributesForInstance:[CRBlurAttributes sharedInstance]];
        if(attributes.enumDescriptor){
            for(NSString* text in [attributes.enumDescriptor.valuesAndLabels allKeys]){
                id enumvalue = [attributes.enumDescriptor.valuesAndLabels valueForKey:text];
                if([enumvalue isEqual:value]){
                    label.text = text;
                    break;
                }
            }
        }else{
            label.text = [NSString stringWithFormat:@"%.2f",[value floatValue]];
        }
    }];
    
    [slider bindEvent:UIControlEventValueChanged withBlock:^{
        [[CRBlurAttributes sharedInstance]setValue:@(slider.value) forKey:name];
    }];
}

@end
