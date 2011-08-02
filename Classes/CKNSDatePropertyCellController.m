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

@interface CKNSDateViewController : CKUIViewController{
    CKObjectProperty* _property;
    UIDatePicker* _datePicker;
}

@property(nonatomic,assign)CKObjectProperty* property;
@property(nonatomic,retain)UIDatePicker* datePicker;

- (id)initWithProperty:(CKObjectProperty*)property;

@end

@implementation CKNSDateViewController
@synthesize property = _property;
@synthesize datePicker = _datePicker;

- (id)initWithProperty:(CKObjectProperty*)theproperty{
    self = [super init];
    self.property = theproperty;
    return self;
}

- (void)dealloc{
    [self clearBindingsContext];
    [_datePicker release];
    _datePicker = nil;
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect frame = [[self view]frame];
    
    CGFloat height = 160;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)){
        height = 216;
    }
    
    CGRect theFrame = CGRectMake((frame.size.width / 2.0) - 160.0,(frame.size.height / 2.0) - height / 2.0,320.0, height);
    self.datePicker = [[[UIDatePicker alloc]initWithFrame:theFrame]autorelease];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
          UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_datePicker setDate:[self.property value]];
    
    [[self view]addSubview:_datePicker];
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [_datePicker bindEvent:UIControlEventValueChanged withBlock:^() {
        [self.property setValue:[_datePicker date]];
    }];
    [self endBindingsContext];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [_datePicker release];
    _datePicker = nil;
}

@end


@implementation CKNSDatePropertyCellController

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
	return self;
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
	cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	
	CKObjectProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
    
    NSDate* date = [model value];
    if(date){
        cell.detailTextLabel.text = [NSValueTransformer transformProperty:model toClass:[NSString class]];
    }
    else{
        cell.detailTextLabel.text = @" ";
    }
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [model.object bind:model.keyPath withBlock:^(id value){
        cell.detailTextLabel.text = [NSValueTransformer transformProperty:model toClass:[NSString class]];
    }];
    [self endBindingsContext];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
    return CKItemViewFlagSelectable;
}


- (void)didSelectRow{
	CKObjectProperty* model = self.value;
	CKClassPropertyDescriptor* descriptor = [model descriptor];
    
    CKNSDateViewController* dateController = [[[CKNSDateViewController alloc]initWithProperty:self.value]autorelease];
    dateController.title = _(descriptor.name);
    
    CKSheetController* sheetController = [[[CKSheetController alloc]initWithContentViewController:dateController]autorelease];
    
    UIView* parentView = self.parentController.view;
    sheetController.delegate = self;
    [sheetController showFromRect:[parentView bounds] inView:parentView animated:YES];
    
    //[self.parentController.navigationController pushViewController:dateController animated:YES];
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
    
}

@end
