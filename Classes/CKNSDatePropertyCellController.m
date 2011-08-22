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

@interface CKNSDateViewController : CKUIViewController{
    CKObjectProperty* _property;
    UIDatePicker* _datePicker;
    id _delegate;
}

@property(nonatomic,assign)CKObjectProperty* property;
@property(nonatomic,retain)UIDatePicker* datePicker;
@property(nonatomic,assign)id delegate;

- (id)initWithProperty:(CKObjectProperty*)property;

@end

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
    self.datePicker = [[[UIDatePicker alloc]initWithFrame:theFrame]autorelease];
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

@end


@implementation CKNSDatePropertyCellController

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
            CKNSDateSheetControllerSingleton = [[CKSheetController alloc]initWithContentViewController:dateController];
            
            CKNSDateSheetControllerSingleton.delegate = self;
            UIView* parentView = self.parentController.view;
            [CKNSDateSheetControllerSingleton showFromRect:[parentView bounds] 
                                                    inView:parentView 
                                                  animated:YES];
        }
        else{
            CKNSDateViewController* dateController = (CKNSDateViewController*)[CKNSDateSheetControllerSingleton contentViewController];
            [dateController setProperty:self.value];
        }
    }
    else{
        [[[self parentController]view]endEditing:YES];//Hides keyboard if needed
        
        CKNSDateViewController* dateController = [[[CKNSDateViewController alloc]initWithProperty:self.value]autorelease];
        dateController.title = _(descriptor.name);
        dateController.delegate = self;
        
        CKPopoverController* popoverController = [[CKPopoverController alloc]initWithContentViewController:dateController];
        
        UITableViewCell* cell = [self tableViewCell];
        [popoverController presentPopoverFromRect:[cell bounds] 
                                 inView:cell 
               permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                               animated:YES];
    }
    
    NSAssert([self.parentController isKindOfClass:[CKTableViewController class]],@"invalid parent controller class");
	CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
	[tableViewController.tableView scrollToRowAtIndexPath:self.indexPath 
                                         atScrollPosition:UITableViewScrollPositionNone 
                                                 animated:YES];
}


- (void)sheetControllerWillShowSheet:(CKSheetController*)sheetController{
    
}

- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController{
    NSAssert([self.parentController isKindOfClass:[CKTableViewController class]],@"invalid parent controller class");
	CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
	[tableViewController.tableView scrollToRowAtIndexPath:self.indexPath 
                                         atScrollPosition:UITableViewScrollPositionNone 
                                                 animated:YES];
}

- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController{
    
}

- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController{

    [CKNSDateSheetControllerSingleton release];
    CKNSDateSheetControllerSingleton = nil;
}

- (void)dateController:(CKNSDateViewController*)controller didSetValue:(NSDate*)value{
    [self setValueInObjectProperty:value];
}

@end
