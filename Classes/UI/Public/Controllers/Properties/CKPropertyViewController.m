//
//  CKPropertyViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyViewController.h"
#import "NSObject+Bindings.h"
#import "CKCollectionCellContentViewController+ResponderChain.h"
#import "UINavigationController+BlockBasedDelegate.h"

@interface CKPropertyViewController ()

@end

@implementation CKPropertyViewController

- (void)dealloc{
    [_property release];
    [_navigationToolbar release];
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
    [self readOnlyDidChange];
}

- (void)readOnlyDidChange{
}

- (BOOL)isValidValue:(id)value{
    CKProperty* property = [self property];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    if(attributes.validationPredicate){
        return [attributes.validationPredicate evaluateWithObject:value];
    }
    return YES;
}

- (UIToolbar*)navigationToolbar{
    if(!self.enableNavigationToolbar)
        return nil;
    
    if(_navigationToolbar == nil){
        UIToolbar* toolbar = [[[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)]autorelease];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        _navigationToolbar = [toolbar retain];
    }
    
    if(self.collectionViewController.state == CKViewControllerStateDidAppear
       || self.collectionViewController.state == CKViewControllerStateWillAppear){
        BOOL hasNextResponder = [self hasNextResponder];
        BOOL hasPreviousResponder = [self hasPreviousResponder];
        NSMutableArray* buttons = [NSMutableArray array];
        {
            UIBarButtonItem* button = [[[UIBarButtonItem alloc]initWithTitle:_(@"Previous")
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(previous:)]autorelease];
            button.enabled = hasPreviousResponder;
            [buttons addObject:button];
        }
        
        UIBarButtonItem* button = [[[UIBarButtonItem alloc]initWithTitle:hasNextResponder ? _(@"Next") : _(@"Done")
                                                                   style:hasNextResponder ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:hasNextResponder ? @selector(next:) : @selector(done:)]autorelease];
        [buttons addObject:button];
        
        CKProperty* model = self.property;
        CKClassPropertyDescriptor* descriptor = [model descriptor];
        NSString* str = [NSString stringWithFormat:@"%@_NavigationBar",descriptor.name];
        NSString* title = _(str);
        if([title isKindOfClass:[NSString class]] && [title length] > 0){
            UILabel* titleLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0,0,200,44)]autorelease];
            titleLabel.name = @"PropertyNavigationBarLabel";
            titleLabel.text = title;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            UIBarButtonItem* titleItem = [[[UIBarButtonItem alloc]initWithCustomView:titleLabel]autorelease];
            [buttons addObject:titleItem];
        }
        
        _navigationToolbar.items = buttons;
        
        NSMutableDictionary* dico = [self controllerStyle];
        [_navigationToolbar applyStyle:dico propertyName:@"navigationToolbar"];
    }
    
    
    return _navigationToolbar;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.contentView.clipsToBounds = YES;
}

- (void)presentEditionViewController:(CKViewController*)controller
                   presentationStyle:(CKPropertyEditionPresentationStyle)presentationStyle
  shouldDismissOnPropertyValueChange:(BOOL)shouldDismissOnPropertyValueChange{
    
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
                [bself.collectionViewController dismissViewControllerAnimated:YES completion:nil];
                [controller clearBindingsContext];
            }];
            
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(shouldDismissOnPropertyValueChange){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bself resignFirstResponder];
                    [bself.collectionViewController dismissViewControllerAnimated:YES completion:nil];
                    [controller clearBindingsContext];
                }];
            }
            [controller endBindingsContext];
            
            [bself.collectionViewController presentViewController:nav animated:YES completion:nil];
            
            break;
        }
        case CKPropertyEditionPresentationStyleSheet:{
            CKSheetController*  sheetController = [CKSheetController sharedInstance];
            
            [sheetController setContentViewController:controller];
            
            if(!sheetController.visible){
                UIView* parentView = self.collectionViewController.view;
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
            
            break;
        }
        case CKPropertyEditionPresentationStyleInline:{
            CKVerticalBoxLayout* vbox = [[CKVerticalBoxLayout alloc]init];
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
    [self didBecomeFirstResponder];
}

- (void)sheetControllerDidShowSheet:(CKSheetController*)sheetController{
}

- (void)sheetControllerWillDismissSheet:(CKSheetController*)sheetController{
    [self didResignFirstResponder];
}

- (void)sheetControllerDidDismissSheet:(CKSheetController*)sheetController{
    sheetController.delegate = nil;
}

@end
