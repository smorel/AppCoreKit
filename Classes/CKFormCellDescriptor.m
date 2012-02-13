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
@synthesize cellController = _cellController;

- (void)dealloc{
    [_value release];
    _value = nil;
    [_cellController release];
    _cellController = nil;
    [super dealloc];
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	return self;
}

- (id)initWithCellController:(CKTableViewCellController*)controller{
    [super init];
	self.value = [controller value];
	self.cellController = controller;
	return self;
}

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass{
	return [[[CKFormCellDescriptor alloc]initWithValue:value controllerClass:controllerClass]autorelease];
}

+ (CKFormCellDescriptor*)cellDescriptorWithCellController:(CKTableViewCellController*)controller{
	return [[[CKFormCellDescriptor alloc]initWithCellController:controller]autorelease];
}

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
    if(_cellController){
        if(_cellController.value == nil){
            [_cellController performSelector:@selector(setValue:) withObject:object];
        }
        [_cellController performSelector:@selector(setIndexPath:) withObject:indexPath];
    }
    else{
        self.cellController = [super controllerForObject:object atIndexPath:indexPath];
        self.value = self.cellController.value;
        self.controllerClass = [_cellController class];
        [_cellController performSelector:@selector(setIndexPath:) withObject:indexPath];
    }
    return _cellController;
}

@end

