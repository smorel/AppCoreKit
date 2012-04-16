//
//  CKNSDatePropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSDatePropertyCellController.h"
#include "CKProperty.h"
#include "CKLocalization.h"
#include "CKNSObject+Bindings.h"
#include "CKNSValueTransformer+Additions.h"
#import "CKPopoverController.h"
#import "CKUIView+Positioning.h"
#import "CKTableViewCellController+Responder.h"

//static CKSheetController* CKNSDateSheetControllerSingleton = nil;
static NSMutableDictionary* CKNSDateSheetControllersSingleton = nil;

@implementation CKNSDateViewController
@synthesize pickerView = _pickerView;
@synthesize property = _property;
@synthesize datePicker = _datePicker;
@synthesize delegate = _delegate;
@synthesize datePickerMode = _datePickerMode;


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
    
    if(_delegate){
        if(_delegate && [_delegate respondsToSelector:@selector(dateController:delegateChanged:)]){
            [_delegate performSelector:@selector(dateController:delegateChanged:) withObject:self withObject:nil];
        }
    }
    
    _delegate = nil;
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
            _datePicker.datePickerMode = UIDatePickerModeDate;
            _datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            /*_datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;*/
            NSDate* date = [self.property value];
            if(date){
                [_datePicker setDate:[self.property value] animated:NO];
            }
            else{
                [_datePicker setDate:[NSDate date] animated:NO];
            }
            
            [[self view]addSubview:_datePicker];
            
            __block CKNSDateViewController* bself = self;
            [self beginBindingsContextByRemovingPreviousBindings];
            [_datePicker bindEvent:UIControlEventValueChanged withBlock:^() {
                NSDate* newDate = [bself.datePicker date];
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
            /*_pickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;*/
            [[self view]addSubview:_pickerView];
            
            _pickerView.showsSelectionIndicator = YES;
            _pickerView.dataSource = self;
            _pickerView.delegate = self;
            
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
                return [NSString stringWithFormat:@"%d",row + 1]; 
            }
            else if(component == 1){//year
                NSDateComponents* comp = [[NSCalendar currentCalendar]components:kCFCalendarUnitYear fromDate:[NSDate date]];
                return [NSString stringWithFormat:@"%d",[comp year] + row]; 
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

- (void)setDelegate:(id)thedelegate{
    if(_delegate){
        if(_delegate && [_delegate respondsToSelector:@selector(dateController:delegateChanged:)]){
            [_delegate performSelector:@selector(dateController:delegateChanged:) withObject:self withObject:thedelegate];
        }
    }
    _delegate = thedelegate;
}

@end

@implementation CKNSDatePropertyCellController
@synthesize onBeginEditingCallback = _onBeginEditingCallback;
@synthesize onEndEditingCallback = _onEndEditingCallback;
@synthesize enableAccessoryView = _enableAccessoryView;
@synthesize datePickerMode = _datePickerMode;

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

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
    _enableAccessoryView = NO;
    self.datePickerMode = CKDatePickerModeDate;
}

- (void)dealloc{
    [_onBeginEditingCallback release];
    _onBeginEditingCallback = nil;
    [_onEndEditingCallback release];
    _onEndEditingCallback = nil;
    [super dealloc];
}

- (void)updateFlags{
    CKProperty* model = self.value;
    if([model isReadOnly] || self.readOnly){
        self.flags = CKItemViewFlagNone;
        return;
    }
    self.flags =  CKItemViewFlagSelectable;
}

- (void)setValue:(id)value{
    [super setValue:value];
    [self updateFlags];
}

- (void)setReadOnly:(BOOL)readOnly{
    [super setReadOnly:readOnly];
    [self updateFlags];
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	
	CKProperty* model = self.value;
    if([model isReadOnly] || self.readOnly){
        self.fixedSize = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        self.fixedSize = NO;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
    
    NSString* placeholderText = [NSString stringWithFormat:@"%@_PlaceHolder",descriptor.name];
    NSDate* date = [model value];
    if(date){
        cell.detailTextLabel.text = [NSValueTransformer transformProperty:model toClass:[NSString class]];
    }
    else{
        cell.detailTextLabel.text = _(placeholderText);
    }
    
    [cell beginBindingsContextByRemovingPreviousBindings];
    [model.object bind:model.keyPath withBlock:^(id value){
        NSDate* date = [model value];
        if(date){
            cell.detailTextLabel.text = [NSValueTransformer transformProperty:model toClass:[NSString class]];
        }
        else{
            cell.detailTextLabel.text = _(placeholderText);
        }
    }];
    [cell endBindingsContext];
}

- (void)didSelectRow{
	[self becomeFirstResponder];
}


- (BOOL)hasResponder{
	return ![self.objectProperty isReadOnly];
}

- (UIView*)nextResponder:(UIView*)view{
    if(view == nil){
        return self.tableViewCell;
    }
    return nil;
}

- (void)becomeFirstResponder{
    CKProperty* model = self.value;
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	
	NSString* propertyNavBarTitle = [NSString stringWithFormat:@"%@_NavBarTitle",descriptor.name];
	NSString* propertyNavBarTitleLocalized = _(propertyNavBarTitle);
	if ([propertyNavBarTitleLocalized isEqualToString:[NSString stringWithFormat:@"%@_NavBarTitle",descriptor.name]]) {
		propertyNavBarTitleLocalized = _(descriptor.name);
	}
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        NSString* dateSheetControllerKey = [NSString stringWithFormat:@"<%d>-<%d>",self.datePickerMode,_enableAccessoryView];
        CKSheetController*  sheetController = [CKNSDateSheetControllersSingleton objectForKey:dateSheetControllerKey];
        if(sheetController == nil){
            CKNSDateViewController* dateController = [[[CKNSDateViewController alloc]initWithProperty:self.value mode:self.datePickerMode]autorelease];
            dateController.title = propertyNavBarTitleLocalized;
            dateController.delegate = self;
            
            if(_enableAccessoryView){
                UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:dateController]autorelease];
                
                //FIXME : This has been commented because it offsets the view up and she appears behind the navigation bar.
                //navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
                sheetController = [[CKSheetController alloc]initWithContentViewController:navController];
            }
            else{
                if(self.enableNavigationToolbar){
                    dateController.navigationItem.titleView = [self navigationToolbar];
                }
                sheetController = [[CKSheetController alloc]initWithContentViewController:dateController];            
            }
            
            [self onBeginEditingUsingViewController:dateController];
            
            sheetController.delegate = self;
            UIView* parentView = self.containerController.view;
            [sheetController showFromRect:[parentView bounds] 
                                   inView:parentView 
                                 animated:YES];
            
            if(CKNSDateSheetControllersSingleton == nil){
                CKNSDateSheetControllersSingleton = [[NSMutableDictionary dictionary]retain];
            }
            [CKNSDateSheetControllersSingleton setObject:sheetController forKey:dateSheetControllerKey];
        }
        else{
            CKNSDateViewController* dateController = nil;
            if(_enableAccessoryView){
                UINavigationController* navController = (UINavigationController*)[sheetController contentViewController];
                dateController = (CKNSDateViewController*)navController.topViewController;
            }
            else{
                dateController = (CKNSDateViewController*)[sheetController contentViewController];
            }
            dateController.title = propertyNavBarTitleLocalized;
            dateController.delegate = self;
            
            [self onBeginEditingUsingViewController:dateController];
            
            sheetController.delegate = self;
            [dateController setProperty:self.value];
            
            [self scrollToRow];
        }
    }
    else{
        [[[self containerController]view]endEditing:YES];//Hides keyboard if needed
        
        CKNSDateViewController* dateController = [[[CKNSDateViewController alloc]initWithProperty:self.value mode:self.datePickerMode]autorelease];
        dateController.title = propertyNavBarTitleLocalized;
        dateController.delegate = self;
        
        [self onBeginEditingUsingViewController:dateController];
        
        CKPopoverController* popoverController = nil;
        if(_enableAccessoryView){
            UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:dateController]autorelease];
            popoverController = [[[CKPopoverController alloc]initWithContentViewController:navController]autorelease];
        }
        else{
            popoverController = [[[CKPopoverController alloc]initWithContentViewController:dateController]autorelease];
        }
        
        UITableViewCell* cell = [self tableViewCell];
        [popoverController presentPopoverFromRect:[cell bounds] 
                                           inView:cell 
                         permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                         animated:YES];
        
        [self scrollToRow];
    }    
}


- (void)sheetControllerWillShowSheet:(CKSheetController*)sheetController{
    [self scrollToRowAfterDelay:0];
}

- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController{
}

- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController{
    [self onEndEditing];
}

- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController{
    NSString* dateSheetControllerKey = [NSString stringWithFormat:@"<%d>-<%d>",self.datePickerMode,_enableAccessoryView];
    [CKNSDateSheetControllersSingleton removeObjectForKey:dateSheetControllerKey];
}

- (void)dateController:(CKNSDateViewController*)controller didSetValue:(NSDate*)value{
    [self setValueInObjectProperty:value];
}

- (void)dateController:(CKNSDateViewController*)controller delegateChanged:(id)delegate{
    if(delegate != self){
        [self onEndEditing];
    }
}

- (void)onBeginEditingUsingViewController:(CKNSDateViewController*)dateViewController{
    if(_onBeginEditingCallback){
        [_onBeginEditingCallback execute:dateViewController];
    }
}

- (void)onEndEditing{
    if(_onEndEditingCallback){
        [_onEndEditingCallback execute:self];
    }
}

@end
