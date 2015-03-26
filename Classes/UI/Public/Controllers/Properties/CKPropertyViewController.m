//
//  CKPropertyViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"
#import "NSObject+Bindings.h"
#import "CKReusableViewController+ResponderChain.h"
#import "UINavigationController+BlockBasedDelegate.h"
#import "CKSheetController.h"
#import "UIViewController+Style.h"
#import "CKPopoverController.h"
#import "UIBarButtonItem+BlockBasedInterface.h"
#import "UIView+Positioning.h"
#import "UIView+Style.h"

@interface CKPropertyViewController ()

@end

@implementation CKPropertyViewController

- (void)dealloc{
    [_propertyNameLabel release];
    [_property release];
    [_editionToolbar release];
    [_propertyEditionTitleLabel release];
    [super dealloc];
}

+ (instancetype)controllerWithProperty:(CKProperty*)property{
    return [[[[self class]alloc]initWithProperty:property]autorelease];
}

+ (instancetype)controllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    return [[[[self class]alloc]initWithProperty:property readOnly:NO]autorelease];
}

- (id)initWithProperty:(CKProperty*)property{
    return [self initWithProperty:property readOnly:NO];
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super init];
    self.property = property;
    self.readOnly = NO;
    self.editionToolbarEnabled = YES;
    self.propertyNameLabel = _(property.name);
    
    NSString* titleKey = [NSString stringWithFormat:@"%@_editionTitle",self.property.descriptor.name];;
    self.propertyEditionTitleLabel = _(titleKey);
    if([self.propertyEditionTitleLabel isEqualToString:titleKey]){
        self.propertyEditionTitleLabel = self.propertyNameLabel;
    }
    
    return self;
}

- (void)setReadOnly:(BOOL)readOnly{
    if([self.property isReadOnly] && !readOnly){
        readOnly = YES;
    }
    
    if(_readOnly == readOnly){
        return;
    }
    
    _readOnly = readOnly;
    
    if(self.readOnly){
        [self resignFirstResponder];
    }
    [self _setupBindings];
}

- (void)setProperty:(CKProperty *)property{
    [_property release];
    _property = [property retain];
    
    [self _setupBindings];
}

- (BOOL)isValidValue:(id)value{
    CKProperty* property = [self property];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    if(attributes.validationPredicate){
        return [attributes.validationPredicate evaluateWithObject:value];
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.view)
        return;
    
    [self.view beginBindingsContextWithScope:@"CKPropertyViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContextWithScope:@"CKPropertyViewController"];
}

- (void)_setupBindings{
    if(self.state != CKViewControllerStateDidAppear || self.view == nil)
        return;
    
    [self.view beginBindingsContextWithScope:@"CKPropertyViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)setupBindings{
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.contentView.clipsToBounds = YES;
}

- (void)endEditing{
    [self.containerViewController.view endEditing:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
}

- (void)presentEditionViewController:(UIViewController*)controller
                   presentationStyle:(CKPropertyEditionPresentationStyle)presentationStyle
  shouldDismissOnPropertyValueChange:(BOOL)shouldDismissOnPropertyValueChange{
    
    controller.stylesheetFileName = self.containerViewController.stylesheetFileName;
    controller.view.backgroundColor = self.containerViewController.view.backgroundColor;
    controller.title = _(self.property.name);
    controller.name = self.property.name;
    
    __unsafe_unretained CKPropertyViewController* bself = self;
    
    CKPropertyEditionPresentationStyle style = presentationStyle;
    if(style == CKPropertyEditionPresentationStyleDefault){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            style = CKPropertyEditionPresentationStylePopover;
        }else if(self.navigationController){
            style = CKPropertyEditionPresentationStylePush;
        }else{
            style = CKPropertyEditionPresentationStyleModal;
        }
    }
    
    if(style != CKPropertyEditionPresentationStyleSheet){
        [self endEditing];
    }
    
    switch(style){
        case CKPropertyEditionPresentationStylePopover:{
            CKPopoverController* popover = [[CKPopoverController alloc]initWithContentViewController:controller];
            [popover presentPopoverFromRect:self.view.frame inView:[self.view superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            __unsafe_unretained CKPopoverController* bPopover = popover;
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(shouldDismissOnPropertyValueChange){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bPopover dismissPopoverAnimated:YES];
                }];
            }
            [controller endBindingsContext];
            
            popover.didDismissPopoverBlock = ^(CKPopoverController* popover){
                [bself resignFirstResponder];
                [controller clearBindingsContext];
            };
            
            break;
        }
        case CKPropertyEditionPresentationStylePush:{
            [self.navigationController pushViewController:controller animated:YES];
            
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(shouldDismissOnPropertyValueChange){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bself.navigationController popViewControllerAnimated:YES];
                }];
            }
            [controller endBindingsContext];
            
            self.navigationController.didPopViewControllerBlock = ^(UINavigationController* navigationController,UIViewController* controller, BOOL animated){
                [bself resignFirstResponder];
                bself.navigationController.didPopViewControllerBlock = nil;
                [controller clearBindingsContext];
            };
            
            break;
        }
        case CKPropertyEditionPresentationStyleModal:{
            UINavigationController* nav = [[[UINavigationController alloc]initWithRootViewController:controller]autorelease];
            
            controller.leftButton = [UIBarButtonItem barButtonItemWithTitle:_(@"Close") style:UIBarButtonItemStyleBordered block:^{
                [bself resignFirstResponder];
                [bself.containerViewController dismissViewControllerAnimated:YES completion:nil];
                [controller clearBindingsContext];
            }];
            
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(shouldDismissOnPropertyValueChange){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bself resignFirstResponder];
                    [bself.containerViewController dismissViewControllerAnimated:YES completion:nil];
                    [controller clearBindingsContext];
                }];
            }
            [controller endBindingsContext];
            
            [bself.containerViewController presentViewController:nav animated:YES completion:nil];
            
            break;
        }
        case CKPropertyEditionPresentationStyleSheet:{
            CKSheetController*  sheetController = [CKSheetController sharedInstance];
            sheetController.delegate = self;
            
            UINavigationController* navController = [UINavigationController navigationControllerWithRootViewController:controller];
            [navController setNavigationBarHidden:YES];
            
            if(self.editionToolbarEnabled){
                navController.navigationItem.titleView = [self editionToolbar];
            }
            
            [sheetController setContentViewController:navController];
            
            if(!sheetController.visible){
                UIView* parentView = self.containerViewController.view;
                [sheetController showFromRect:[parentView bounds]
                                       inView:parentView
                                     animated:YES];
            }
            
            [controller beginBindingsContextByRemovingPreviousBindings];
            [NSNotificationCenter bindNotificationName:CKSheetResignNotification withBlock:^(NSNotification *notification) {
                [bself resignFirstResponder];
                [controller clearBindingsContext];
            }];
            [controller endBindingsContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToCell];
            });
            
            break;
        }
        case CKPropertyEditionPresentationStyleInline:{
            CKVerticalBoxLayout* vbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
            vbox.name = @"InlineEditionControllerLayout";
            vbox.paddingTop = self.view.height;
            if(controller.layoutBoxes.count > 0){
                controller.view.flexibleSize = NO;
            }else{
                controller.view.fixedHeight = 216;
            }
            vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[controller]];
            
            [self.view addLayoutBox:vbox];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToCell];
            });
            
            break;
        }
    }
}

- (void)resignFirstResponder{
    [super resignFirstResponder];
    
    CKVerticalBoxLayout* vbox = (CKVerticalBoxLayout*)[self.view layoutWithName:@"InlineEditionControllerLayout"];
    if(vbox){
        [self.view removeLayoutBox:vbox];
    }
}

- (void)sheetControllerWillShowSheet:(CKSheetController*)sheetController{
}

- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController{
}

- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController{
    [self resignFirstResponder];
}

- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController{
    sheetController.delegate = nil;
}


- (UIToolbar*)editionToolbar{
    if(!self.editionToolbarEnabled)
        return nil;
    
    if(_editionToolbar == nil){
        UIToolbar* toolbar = [[[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)]autorelease];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        _editionToolbar = [toolbar retain];
    }
    
    if(self.containerViewController.state == CKViewControllerStateDidAppear
       || self.containerViewController.state == CKViewControllerStateWillAppear){
        BOOL hasNextResponder = [self hasNextResponder];
        BOOL hasPreviousResponder = [self hasPreviousResponder];
        NSMutableArray* buttons = [NSMutableArray array];
        {
            UIBarButtonItem* button = [[[UIBarButtonItem alloc]initWithTitle:_(@"Previous")
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(previous:)]autorelease];
            button.name = @"PreviousBarButtonItem";
            button.enabled = hasPreviousResponder;
            [buttons addObject:button];
        }
        
        UIBarButtonItem* button = [[[UIBarButtonItem alloc]initWithTitle:hasNextResponder ? _(@"Next") : _(@"Done")
                                                                   style:hasNextResponder ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:hasNextResponder ? @selector(next:) : @selector(done:)]autorelease];
        button.name = hasNextResponder ? @"NextBarButtonItem" : @"DoneBarButtonItem";
        [buttons addObject:button];
        
        CKProperty* model = self.property;
        CKClassPropertyDescriptor* descriptor = [model descriptor];
        NSString* title = self.propertyEditionTitleLabel;
        if([title isKindOfClass:[NSString class]] && [title length] > 0){
            UILabel* titleLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0,0,200,44)]autorelease];
            titleLabel.name = @"EditionLabel";
            titleLabel.text = title;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            UIBarButtonItem* titleItem = [[[UIBarButtonItem alloc]initWithCustomView:titleLabel]autorelease];
            [buttons addObject:titleItem];
        }
        
        _editionToolbar.items = buttons;
        
        NSMutableDictionary* dico = [self controllerStyle];
        [_editionToolbar applyStyle:dico propertyName:@"editionToolbar"];
    }
    
    
    return _editionToolbar;
}

- (void)done:(id)sender{
    [self resignFirstResponder];
}

- (void)next:(id)sender{
    [self activateNextResponder];
}

- (void)previous:(id)sender{
    [self activatePreviousResponder];
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

@end
