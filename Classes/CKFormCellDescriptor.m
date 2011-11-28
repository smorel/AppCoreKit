//
//  CKFormCellDescriptor.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormCellDescriptor.h"

//Private interfaces
@interface CKItemViewControllerFactoryItem() 
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end


//CKFormCellDescriptor

@implementation CKFormCellDescriptor
@synthesize value = _value;
@synthesize viewController = _viewController;

- (void)dealloc{
    [_value release];
    _value = nil;
    [_viewController release];
    _viewController = nil;
    [super dealloc];
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	return self;
}

- (id)initWithItemViewController:(CKItemViewController*)controller{
    [super init];
	self.value = [controller value];
	self.viewController = controller;
	return self;
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass]autorelease];
}

+ (CKFormCellDescriptor*)cellDescriptorWithItemViewController:(CKItemViewController*)controller{
	return [[[CKFormCellDescriptor alloc]initWithItemViewController:controller]autorelease];
}

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    if(_viewController){
        [_viewController performSelector:@selector(setValue:) withObject:object];
        [_viewController performSelector:@selector(setIndexPath:) withObject:indexPath];
    }
    else{
        self.viewController = [super controllerForObject:object atIndexPath:indexPath];
    }
    return _viewController;
}

@end

