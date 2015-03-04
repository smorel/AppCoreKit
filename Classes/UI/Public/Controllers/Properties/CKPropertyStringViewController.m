//
//  CKPropertyStringViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyStringViewController.h"
#import "CKTextView.h"
#import "CKLocalization.h"

@interface CKPropertyStringViewController ()

@end

@implementation CKPropertyStringViewController

- (void)dealloc{
    [_textInputFormatter release];
    [_propertyNameLabel release];
    [_valuePlaceholderLabel release];
    [super dealloc];
}

#pragma mark ViewController Life Cycle

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    self.multiline = attributes.multiLineEnabled;
    self.minimumLength = attributes.minimumLength;
    self.maximumLength = attributes.maximumLength;
    self.textInputFormatter = attributes.textInputFormatterBlock;
    self.propertyNameLabel = _(property.name);
    
    NSString* placeholderKey = [NSString stringWithFormat:@"%@_placeholder",property.name];
    self.valuePlaceholderLabel = _(placeholderKey);
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    self.view.minimumHeight = 44;
    
    UILabel* PropertyNameLabel = [[UILabel alloc]init];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    PropertyNameLabel.marginRight = 10;
    PropertyNameLabel.marginBottom = 10;
    
    UITextField* ValueTextField = [[UITextField alloc]init];
    ValueTextField.name = @"ValueTextField";
    ValueTextField.font = [UIFont systemFontOfSize:14];
    ValueTextField.minimumWidth = 100;
    
    CKTextView* ValueTextView = [[CKTextView alloc]init];
    ValueTextView.name = @"ValueTextView";
    ValueTextView.font = [UIFont systemFontOfSize:14];
    
    CKHorizontalBoxLayout* hBox = [[CKHorizontalBoxLayout alloc]init];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,ValueTextField]];
    
    CKVerticalBoxLayout* vBox = [[CKVerticalBoxLayout alloc]init];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox,ValueTextView]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vBox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setup];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContext];
}

- (void)setup{
    if(!self.view)
        return;
    
    [self.view beginBindingsContextByRemovingPreviousBindings];
    [self setupBindings];
    [self.view endBindingsContext];
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UITextField* ValueTextField = [self.view viewWithName:@"ValueTextField"];
    ValueTextField.placeholder = self.valuePlaceholderLabel;
    ValueTextField.delegate = self;
    
    CKTextView* ValueTextView = [self.view viewWithName:@"ValueTextView"];
    ValueTextView.placeholder = self.valuePlaceholderLabel;
    ValueTextField.delegate = self;
    
    ValueTextField.hidden = self.multiline;
    ValueTextView.hidden = !ValueTextField.hidden;
    ValueTextField.userInteractionEnabled = ValueTextView.userInteractionEnabled = !self.readOnly;
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
        NSString* str = [value isKindOfClass:[NSString class]] ? value : nil;
        if(![ValueTextField.text isEqualToString:str]){
            ValueTextField.text = str;
        }
    }];
    
    [[NSNotificationCenter defaultCenter] bindNotificationName:UITextFieldTextDidChangeNotification object:ValueTextField
                                                     withBlock:^(NSNotification *notification) {
                                                         [self textFieldChanged:ValueTextField.text];
                                                     }];

}

@end
