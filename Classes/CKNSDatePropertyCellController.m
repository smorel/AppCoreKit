//
//  CKNSDatePropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSDatePropertyCellController.h"
#include "CKObjectProperty.h"
#include "CKLocalization.h"
#include "CKNSObject+Bindings.h"
#include "CKNSValueTransformer+Additions.h"
#import "CKPopoverController.h"

static CKSheetController* CKNSDateSheetControllerSingleton = nil;

@implementation CKNSDateViewController
@synthesize property = _property;
@synthesize datePicker = _datePicker;
@synthesize delegate = _delegate;

- (id)initWithProperty:(CKObjectProperty*)theproperty{
    self = [super init];
    _property = [theproperty retain];
    return self;
}

- (void)dealloc{
    [self clearBindingsContext];
    [_datePicker release];
    _datePicker = nil;
    
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
    
    CGRect frame = [[self view]frame];
    
    CGFloat height = 162;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)){
        height = 216;
    }
    
    CGRect theFrame = CGRectMake((frame.size.width / 2.0) - 160.0,(frame.size.height / 2.0) - height / 2.0,320.0, height);
    self.datePicker = [[[UIDatePicker alloc]initWithFrame:CGRectIntegral(theFrame)]autorelease];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
          UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
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
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [_datePicker release];
    _datePicker = nil;
}

- (void)setProperty:(CKObjectProperty *)property{
    [_property release];
    _property = [property retain];
    NSDate* date = [_property value];
    [_datePicker setDate:(date ? date : [NSDate date])];
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

- (id)init{
    self = [super init];
    _enableAccessoryView = NO;
    return self;
}

- (void)dealloc{
    [_onBeginEditingCallback release];
    _onBeginEditingCallback = nil;
    [_onEndEditingCallback release];
    _onEndEditingCallback = nil;
    [super dealloc];
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	
	CKObjectProperty* model = self.value;
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
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [model.object bind:model.keyPath withBlock:^(id value){
        NSDate* date = [model value];
        if(date){
            cell.detailTextLabel.text = [NSValueTransformer transformProperty:model toClass:[NSString class]];
        }
        else{
            cell.detailTextLabel.text = _(placeholderText);
        }
    }];
    [self endBindingsContext];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
    CKNSDatePropertyCellController* staticController = (CKNSDatePropertyCellController*)[params staticController];
	CKObjectProperty* model = object;
    if([model isReadOnly] || staticController.readOnly){
        return CKItemViewFlagNone;
    }
    return CKItemViewFlagSelectable;
}


- (void)didSelectRow{
	CKObjectProperty* model = self.value;
	CKClassPropertyDescriptor* descriptor = [model descriptor];
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(CKNSDateSheetControllerSingleton == nil){
            CKNSDateViewController* dateController = [[[CKNSDateViewController alloc]initWithProperty:self.value]autorelease];
            dateController.title = _(descriptor.name);
            dateController.delegate = self;
            
            if(_enableAccessoryView){
                UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:dateController]autorelease];
                CKNSDateSheetControllerSingleton = [[CKSheetController alloc]initWithContentViewController:navController];
            }
            else{
                CKNSDateSheetControllerSingleton = [[CKSheetController alloc]initWithContentViewController:dateController];            
            }
            
            [self onBeginEditingUsingViewController:dateController];
            
            CKNSDateSheetControllerSingleton.delegate = self;
            UIView* parentView = self.parentController.view;
            [CKNSDateSheetControllerSingleton showFromRect:[parentView bounds] 
                                                    inView:parentView 
                                                  animated:YES];
        }
        else{
            CKNSDateViewController* dateController = nil;
            if(_enableAccessoryView){
                UINavigationController* navController = (UINavigationController*)[CKNSDateSheetControllerSingleton contentViewController];
                dateController = (CKNSDateViewController*)navController.topViewController;
            }
            else{
                dateController = (CKNSDateViewController*)[CKNSDateSheetControllerSingleton contentViewController];
            }
            dateController.title = _(descriptor.name);
            dateController.delegate = self;
            
            [self onBeginEditingUsingViewController:dateController];
            
            CKNSDateSheetControllerSingleton.delegate = self;
            [dateController setProperty:self.value];
            
            [self scrollToRow];
        }
    }
    else{
        [[[self parentController]view]endEditing:YES];//Hides keyboard if needed
        
        CKNSDateViewController* dateController = [[[CKNSDateViewController alloc]initWithProperty:self.value]autorelease];
        dateController.title = _(descriptor.name);
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
    
}

- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController{
    [self scrollToRowAfterDelay:0.3];
}

- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController{
    [self onEndEditing];
}

- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController{
    [CKNSDateSheetControllerSingleton release];
    CKNSDateSheetControllerSingleton = nil;
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
