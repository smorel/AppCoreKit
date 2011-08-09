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
#import "CKNSNotificationCenter+Edition.h"

static CKSheetController* CKNSDateSheetControllerSingleton = nil;

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
    _property = [theproperty retain];
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
    [_datePicker setDate:[self.property value] animated:NO];
    
    [[self view]addSubview:_datePicker];
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [_datePicker bindEvent:UIControlEventValueChanged withBlock:^() {
        [self.property setValue:[_datePicker date]];
		[[NSNotificationCenter defaultCenter]notifyPropertyChange:self.property];
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
    [_datePicker setDate:[_property value]];
}

@end



@interface CKNSDatePropertyCellController()
@property(nonatomic,retain)UIPopoverController* popoverController;
@end

@implementation CKNSDatePropertyCellController
@synthesize popoverController;

- (void)dealloc{
    self.popoverController = nil;
    [super dealloc];
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	
	CKObjectProperty* model = self.value;
    if([model isReadOnly] || self.readOnly){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
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
        
        CGFloat height = 160;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
        if(UIInterfaceOrientationIsPortrait(orientation)){
            height = 216;
        }
        dateController.contentSizeForViewInPopover = CGSizeMake(320,height);
        
        self.popoverController = [[UIPopoverController alloc]initWithContentViewController:dateController];
        self.popoverController.delegate = self;
        
        UITableViewCell* cell = [self tableViewCell];
        [self.popoverController presentPopoverFromRect:[cell bounds] 
                                 inView:cell 
               permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                               animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    self.popoverController = nil;
}

- (void)orientationChanged:(NSNotification*)notif{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

@end
