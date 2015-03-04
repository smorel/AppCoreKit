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


@end
