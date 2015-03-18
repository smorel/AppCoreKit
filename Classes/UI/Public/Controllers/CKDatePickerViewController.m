//
//  CKDatePickerViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKDatePickerViewController.h"
#import "CKWeakRef.h"
#import "UIView+Positioning.h"
#import "NSObject+Bindings.h"


@interface CKDatePickerViewController()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,retain) CKWeakRef* delegateRef;
@end

@implementation CKDatePickerViewController{
    CKProperty* _property;
    UIDatePicker* _datePicker;
    UIPickerView* _pickerView;
    CKDatePickerMode _datePickerMode;
    id _delegate;
}


@synthesize pickerView = _pickerView;
@synthesize property = _property;
@synthesize datePicker = _datePicker;
@synthesize delegate;
@synthesize datePickerMode = _datePickerMode;
@synthesize delegateRef = _delegateRef;


- (void)datePickerModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
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

- (id)initWithProperty:(CKProperty*)theproperty mode:(CKDatePickerMode)mode{
    self = [super init];
    _property = [theproperty retain];
    self.datePickerMode = mode;
    return self;
}

- (void)dealloc{
    [self clearBindingsContext];
    [_datePicker release];
    _datePicker = nil;
    [_pickerView release];
    _pickerView = nil;
    
    if(_delegateRef){
        if(_delegateRef.object && [_delegateRef.object respondsToSelector:@selector(dateController:delegateChanged:)]){
            [_delegateRef.object performSelector:@selector(dateController:delegateChanged:) withObject:self withObject:nil];
        }
    }
    
    [_delegateRef release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGFloat height = 162;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)){
        height = 216;
    }
    
    self.view.height = height;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect frame = [[self view]frame];
    CGRect theFrame = CGRectMake((frame.size.width / 2.0) - 160.0,(frame.size.height / 2.0) - (height / 2.0),320.0, height);
    
    switch(self.datePickerMode){
        case  CKDatePickerModeTime:
        case CKDatePickerModeDate:
        case CKDatePickerModeDateAndTime:
        case CKDatePickerModeCountDownTime :{
            self.datePicker = [[[UIDatePicker alloc]initWithFrame:CGRectIntegral(theFrame)]autorelease];
            _datePicker.datePickerMode = self.datePickerMode;
            _datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            
            CKPropertyExtendedAttributes* attributes = [self.property extendedAttributes];
            if(attributes.minimumDate){
                _datePicker.minimumDate = attributes.minimumDate;
            }
            if(attributes.maximumDate){
                _datePicker.maximumDate = attributes.maximumDate;
            }
            if(attributes.minuteInterval >= 0){
                _datePicker.minuteInterval = attributes.minuteInterval;
            }
            
            
            
            /*_datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;*/
            NSDate* date = [self.property value];
            if(date){
                [_datePicker setDate:date animated:NO];
            }
            else{
                [_datePicker setDate:[NSDate date] animated:NO];
            }
            
            [[self view]addSubview:_datePicker];
            
            __block CKDatePickerViewController* bself = self;
            [self beginBindingsContextByRemovingPreviousBindings];
            [_datePicker bindEvent:UIControlEventValueChanged withBlock:^() {
                NSDate* newDate = [bself.datePicker date];
                [bself.property setValue:newDate];
                if(bself.delegate && [bself.delegate respondsToSelector:@selector(dateController:didSetValue:)]){
                    [bself.delegate performSelector:@selector(dateController:didSetValue:) withObject:bself withObject:newDate];
                }
            }];
            [self endBindingsContext];
            
            //Adjust if navigationController with transparent toolbar
            CGFloat y = self.view.frame.size.height - self.datePicker.frame.size.height;
            self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x,
                                               y,
                                               self.datePicker.frame.size.width,
                                               self.datePicker.frame.size.height);
            
            break;
        }
        case CKDatePickerModeCreditCardExpirationDate:{
            self.pickerView = [[[UIPickerView alloc]initWithFrame:CGRectIntegral(theFrame)]autorelease];
            _pickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            /*_pickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;*/
            [[self view]addSubview:_pickerView];
            
            _pickerView.showsSelectionIndicator = YES;
            _pickerView.dataSource = self;
            _pickerView.delegate = self;
            
            NSDate* date = [self.property value];
            if(!date){
                date = [NSDate date];
            }
            
            NSDateComponents* comp2 = [[NSCalendar currentCalendar]components:kCFCalendarUnitYear fromDate:[NSDate date]];
            NSDateComponents* comp = [[NSCalendar currentCalendar]components:kCFCalendarUnitYear|kCFCalendarUnitMonth fromDate:date];
            NSInteger yearRow = [comp year] - [comp2 year];
            NSInteger monthRow = [comp month] - 1;
            
            [_pickerView selectRow:monthRow inComponent:0 animated:NO];
            [_pickerView selectRow:yearRow inComponent:1 animated:NO];
            
            //Adjust if navigationController with transparent toolbar
            CGFloat y = self.view.frame.size.height - self.pickerView.frame.size.height;
            self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x,
                                               y,
                                               self.pickerView.frame.size.width,
                                               self.pickerView.frame.size.height);
            break;
        }
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch(self.datePickerMode){
        case CKDatePickerModeCreditCardExpirationDate:{
            return 2;
        }
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch(self.datePickerMode){
        case CKDatePickerModeCreditCardExpirationDate:{
            if(component == 0){//month
                return 12;
            }
            else if(component == 1){//year
                return 10;
            }
        }
    }
    return 0;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch(self.datePickerMode){
        case CKDatePickerModeCreditCardExpirationDate:{
            if(component == 0){//month
                NSInteger index = row + (NSInteger)1;
                return [NSString stringWithFormat:@"%ld",(long)index];
            }
            else if(component == 1){//year
                NSDateComponents* comp = [[NSCalendar currentCalendar]components:kCFCalendarUnitYear fromDate:[NSDate date]];
                return [NSString stringWithFormat:@"%ld",(long)([comp year] + row)];
            }
            break;
        }
    }
    return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch(self.datePickerMode){
        case CKDatePickerModeCreditCardExpirationDate:{
            NSDateComponents* comp = [[[NSDateComponents alloc]init]autorelease];
            [comp setMonth:1 + [self.pickerView selectedRowInComponent:0]];
            
            NSDateComponents* comp2 = [[NSCalendar currentCalendar]components:kCFCalendarUnitYear fromDate:[NSDate date]];
            [comp setYear:[comp2 year] + [self.pickerView selectedRowInComponent:1]];
            
            NSDate* newDate = [[NSCalendar currentCalendar]dateFromComponents:comp];
            
            [self.property setValue:newDate];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(dateController:didSetValue:)]){
                [self.delegate performSelector:@selector(dateController:didSetValue:) withObject:self withObject:newDate];
            }
            break;
        }
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [_datePicker release];
    _datePicker = nil;
    [_pickerView release];
    _pickerView = nil;
}

- (void)setProperty:(CKProperty *)property{
    [_property release];
    _property = [property retain];
    NSDate* date = [_property value];
    if(_datePicker){
        _datePicker.minimumDate = nil;
        _datePicker.maximumDate = nil;
        
        CKPropertyExtendedAttributes* attributes = [self.property extendedAttributes];
        if(attributes.minimumDate){
            _datePicker.minimumDate = attributes.minimumDate;
        }
        if(attributes.maximumDate){
            _datePicker.maximumDate = attributes.maximumDate;
        }
        
        [_datePicker setDate:(date ? date : [NSDate date])];
    }
    else{
        //TODO
    }
}

- (CGSize)contentSizeForViewInPopover{
    CGFloat height = 160;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)){
        height = 216;
    }
    return CGSizeMake(320,height);
}

- (id)delegate{
    return [self.delegateRef object];
}

- (void)setDelegate:(id)thedelegate{
    if(self.delegate){
        if(self.delegate && [self.delegate respondsToSelector:@selector(dateController:delegateChanged:)]){
            [self.delegate performSelector:@selector(dateController:delegateChanged:) withObject:self withObject:thedelegate];
        }
    }
    self.delegateRef = [CKWeakRef weakRefWithObject:thedelegate];
}

@end
