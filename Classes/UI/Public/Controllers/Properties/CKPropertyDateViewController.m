//
//  CKPropertyDateViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyDateViewController.h"
#import "NSDate+Conversions.h"
#import "CKCollectionCellContentViewController+ResponderChain.h"


@interface CKPropertyDateViewController ()
@end

@implementation CKPropertyDateViewController

- (void)dealloc{
    [_propertyNameLabel release];
    [_dateFormatter release];
    [_valuePlaceholderLabel release];
    [_editionControllerPickerMinimumDate release];
    [_editionControllerPickerMaximumDate release];
    [super dealloc];
}

- (void)editionControllerPresentationStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKPropertyEditionPresentationStyle",
                                                 CKPropertyEditionPresentationStyleDefault,
                                                 CKPropertyEditionPresentationStylePush,
                                                 CKPropertyEditionPresentationStylePopover,
                                                 CKPropertyEditionPresentationStyleModal,
                                                 CKPropertyEditionPresentationStyleSheet,
                                                 CKPropertyEditionPresentationStyleInline);
}

#pragma mark ViewController Life Cycle

static NSDateFormatter* sharedFormatter = nil;

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    self.propertyNameLabel = _(property.name);
    
    self.editionControllerPickerMode = CKDatePickerModeDate;
    
    if(self.valuePlaceholderLabel == nil){
        NSString* placeholderKey = [NSString stringWithFormat:@"%@_placeholder",property.name];
        self.valuePlaceholderLabel = _(placeholderKey);
    }
    
    if(!sharedFormatter){
        sharedFormatter = [[NSDateFormatter alloc]init];
        sharedFormatter.dateStyle = NSDateFormatterLongStyle;
        sharedFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    self.editionControllerPickerMinuteInterval = NSNotFound;
    self.editionControllerPresentationStyle = CKPropertyEditionPresentationStyleInline;
    
    return self;
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
    
    UILabel* ValueLabel = [[UILabel alloc]init];
    ValueLabel.name = @"ValueLabel";
    ValueLabel.font = [UIFont systemFontOfSize:14];
    ValueLabel.textColor = [UIColor blackColor];
    ValueLabel.numberOfLines = 1;
    
    CKHorizontalBoxLayout* hBox = [[CKHorizontalBoxLayout alloc]init];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,[[[CKLayoutFlexibleSpace alloc]init]autorelease],ValueLabel]];
    
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
    __unsafe_unretained CKPropertyDateViewController* bself = self;
    
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UILabel* ValueLabel = [self.view viewWithName:@"ValueLabel"];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        if(bself.property.value){
            NSDateFormatter* formatter = bself.dateFormatter ? bself.dateFormatter : sharedFormatter;
            ValueLabel.text = [formatter stringFromDate:bself.property.value];
        }else{
            ValueLabel.text = _(bself.valuePlaceholderLabel);
        }
    }];
}

- (void)didSelect{
    [super didSelect];
    if(self.isFirstResponder){
        if(self.editionControllerPresentationStyle == CKPropertyEditionPresentationStyleInline){
            [self resignFirstResponder];
        }
    }else{
        [self becomeFirstResponder];
    }
}

- (BOOL)hasResponder{
    return YES;
}

- (void)becomeFirstResponder{
    [super becomeFirstResponder];
    
    CKDatePickerViewController* picker = [[CKDatePickerViewController alloc]initWithProperty:self.property mode:self.editionControllerPickerMode];
    
    NSDateFormatter* formatter = self.dateFormatter ? self.dateFormatter : sharedFormatter;
    picker.timeZone = formatter.timeZone;
    picker.locale = formatter.locale;
    picker.calendar = formatter.calendar;
    picker.minimumDate = self.editionControllerPickerMinimumDate;
    picker.maximumDate = self.editionControllerPickerMaximumDate;
    picker.minuteInterval = self.editionControllerPickerMinuteInterval;
    
    [self presentEditionViewController:picker presentationStyle:self.editionControllerPresentationStyle shouldDismissOnPropertyValueChange:NO];
}

- (void)editionControllerPickerModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKDatePickerMode",
                                                 CKDatePickerModeTime,
                                                 UIDatePickerModeTime,
                                                 CKDatePickerModeDate,
                                                 UIDatePickerModeDate,
                                                 CKDatePickerModeDateAndTime,
                                                 UIDatePickerModeDateAndTime,
                                                 CKDatePickerModeCountDownTime,
                                                 UIDatePickerModeCountDownTimer,
                                                 CKDatePickerModeCreditCardExpirationDate);
}

- (void)dateFormatterExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [NSDateFormatter class];
}

@end
