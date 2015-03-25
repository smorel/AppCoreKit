//
//  CKNSDatePropertyCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSDatePropertyCellController.h"
#include "CKProperty.h"
#include "CKLocalization.h"
#include "NSObject+Bindings.h"
#include "NSValueTransformer+Additions.h"
#import "CKPopoverController.h"
#import "UIView+Positioning.h"
#import "CKTableViewCellController+Responder.h"
#import "CKWeakRef.h"

static CKSheetController* CKNSDateSheetControllerSingleton = nil;
static NSMutableDictionary* CKNSDateSheetControllersSingleton = nil;


@interface CKCollectionCellController()
@property (nonatomic, assign, readwrite) CKCollectionViewControllerOld* containerController;
@end


@implementation CKNSDatePropertyCellController {
    CKCallback* _onBeginEditingCallback;
    CKCallback* _onEndEditingCallback;
    BOOL _enableAccessoryView;
    CKDatePickerMode _datePickerMode;
}

@synthesize onBeginEditingCallback = _onBeginEditingCallback;
@synthesize onEndEditingCallback = _onEndEditingCallback;
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

- (void)setContainerController:(CKCollectionViewControllerOld *)containerController{
    [super setContainerController:containerController];
    
    __block CKNSDatePropertyCellController* bself = self;
    [NSObject beginBindingsContext:[NSString stringWithFormat:@"Resign_<%p>",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
    [containerController bind:@"state" withBlock:^(id value) {
        if(bself.containerController.state == CKViewControllerStateWillDisappear
           || bself.containerController.state == CKViewControllerStateDidDisappear){
            [bself resignFirstResponder];
        }
    }];
    [NSObject endBindingsContext];
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"Resign_<%p>",self]];
    [_onBeginEditingCallback release];
    _onBeginEditingCallback = nil;
    [_onEndEditingCallback release];
    _onEndEditingCallback = nil;
    [super dealloc];
}

- (void)updateFlags{
    CKProperty* model = self.objectProperty;
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

- (void)onValueChanged{
    CKProperty* model = self.objectProperty;
    if([model isReadOnly] || self.readOnly){
        self.fixedSize = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        self.fixedSize = NO;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	self.text = _(descriptor.name);
    
    NSString* placeholderText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
    NSDate* date = [model value];
    if(date){
        self.detailText = [NSValueTransformer transformProperty:model toClass:[NSString class]];
    }
    else{
        self.detailText  = _(placeholderText);
    }
    
    __block CKNSDatePropertyCellController* bself = self;
    [self beginBindingsContextByRemovingPreviousBindings];
    [model.object bind:model.keyPath executeBlockImmediatly:YES withBlock:^(id value){
        NSDate* date = [model value];
        NSString* str = nil;
        if(date){
            str  = [NSValueTransformer transformProperty:model toClass:[NSString class]];
        }
        else{
            str  = _(placeholderText);
        }
        if(![bself.detailText isEqualToString:str]){
            bself.detailText = str;
        }
    }];
    [self endBindingsContext];
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

- (void)resignFirstResponder{
    NSString* dateSheetControllerKey = [NSString stringWithFormat:@"<%ld>-<%d>",(long)self.datePickerMode,_enableAccessoryView];
    CKSheetController*  sheetController = [CKNSDateSheetControllersSingleton objectForKey:dateSheetControllerKey];
    if(sheetController && sheetController.visible){
        [sheetController dismissSheetAnimated:YES];
    }
}

- (void)becomeFirstResponder{
    [super becomeFirstResponder];
    
    CKProperty* model = self.objectProperty;
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	
	NSString* propertyNavBarTitle = self.enableNavigationToolbar ? [NSString stringWithFormat:@"%@_NavBarTitle",descriptor.name] : nil;
	NSString* propertyNavBarTitleLocalized = propertyNavBarTitle ? _(propertyNavBarTitle) : nil;
	if (propertyNavBarTitleLocalized && [propertyNavBarTitleLocalized isEqualToString:[NSString stringWithFormat:@"%@_NavBarTitle",descriptor.name]]) {
		propertyNavBarTitleLocalized = _(descriptor.name);
	}
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        NSString* dateSheetControllerKey = [NSString stringWithFormat:@"<%ld>-<%d>",(long)self.datePickerMode,_enableAccessoryView];
        CKSheetController*  sheetController = [CKNSDateSheetControllersSingleton objectForKey:dateSheetControllerKey];
        if(sheetController == nil){
            CKDatePickerViewController* dateController = [[[CKDatePickerViewController alloc]initWithProperty:self.objectProperty mode:self.datePickerMode]autorelease];
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
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CKNSDateSheetControllersSingleton = [[NSMutableDictionary dictionary]retain];
            });
            [CKNSDateSheetControllersSingleton setObject:sheetController forKey:dateSheetControllerKey];
            
            [self scrollToRow];
        }
        else{
            CKDatePickerViewController* dateController = nil;
            if(_enableAccessoryView){
                UINavigationController* navController = (UINavigationController*)[sheetController contentViewController];
                dateController = (CKDatePickerViewController*)navController.topViewController;
            }
            else{
                dateController = (CKDatePickerViewController*)[sheetController contentViewController];
                if(self.enableNavigationToolbar){
                    dateController.navigationItem.titleView = [self navigationToolbar];
                }
            }
            dateController.title = propertyNavBarTitleLocalized;
            dateController.delegate = self;
            
            [self onBeginEditingUsingViewController:dateController];
            
            sheetController.delegate = self;
            [dateController setProperty:self.objectProperty];
            
            
            if(!sheetController.visible){
                UIView* parentView = self.containerController.view;
                [sheetController showFromRect:[parentView bounds] 
                                       inView:parentView 
                                     animated:YES];
            }
            
            [self scrollToRow];
        }
    }
    else{
        [[[self containerController]view]endEditing:YES];//Hides keyboard if needed
        
        CKDatePickerViewController* dateController = [[[CKDatePickerViewController alloc]initWithProperty:self.objectProperty mode:self.datePickerMode]autorelease];
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
    NSString* dateSheetControllerKey = [NSString stringWithFormat:@"<%ld>-<%d>",(long)self.datePickerMode,_enableAccessoryView];
    [CKNSDateSheetControllersSingleton removeObjectForKey:dateSheetControllerKey];
}

- (void)dateController:(CKDatePickerViewController*)controller didSetValue:(NSDate*)value{
    [self setValueInObjectProperty:value];
}

- (void)dateController:(CKDatePickerViewController*)controller delegateChanged:(id)delegate{
    if(delegate != self){
        [self onEndEditing];
    }
}

- (void)onBeginEditingUsingViewController:(CKDatePickerViewController*)dateViewController{
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
