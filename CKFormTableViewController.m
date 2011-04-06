//
//  CKFormTableViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h";


@interface CKFormObjectController : NSObject<CKObjectController>{
	id _delegate;
}
@property (nonatomic, assign) id delegate;
@end

@implementation CKFormObjectController
@synthesize delegate = _delegate;

- (NSInteger)numberOfSections{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	return [formController.sections count];
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:section];
	return [formSection.cellDescriptors count];
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:section];
	return formSection.headerTitle;
}

- (UIView*)headerViewForSection:(NSInteger)section{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:section];
	return formSection.headerView;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormTableViewController* formController = (CKFormTableViewController*)self.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	return cellDescriptor.value;
}

- (void)setDelegate:(id)theDelegate{
	self.delegate = theDelegate;
}

@end


@interface CKFormObjectControllerFactory : CKObjectViewControllerFactory{
}
@end

@implementation CKFormObjectControllerFactory

- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	return cellDescriptor.controllerClass;
}

- (id)styleForIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	return cellDescriptor.controllerStyle;
}

- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath{
	CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.delegate;
	CKFormSection* formSection = [formController.sections objectAtIndex:indexPath.section];
	CKFormCellDescriptor* cellDescriptor = [formSection.cellDescriptors objectAtIndex:indexPath.row];
	if(cellDescriptor.block){
		cellDescriptor.block(controller);
	}
	else if(cellDescriptor.target){
		[cellDescriptor.target performSelector:cellDescriptor.action withObject:controller];
	}
}

@end







@implementation CKFormSection
@synthesize headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize cellDescriptors = _cellDescriptors;

- (id)initWithHeaderTitle:(NSString*)title cellDescriptors:(NSArray*)theCellDescriptors{
	[super init];
	self.headerTitle = title;
	self.cellDescriptors = [NSMutableArray arrayWithArray:theCellDescriptors];
	return self;
}

- (id)initWithHeaderView:(UIView*)view cellDescriptors:(NSArray*)theCellDescriptors{
	[super init];
	self.headerView = view;
	self.cellDescriptors = [NSMutableArray arrayWithArray:theCellDescriptors];
	return self;
}

@end

@implementation CKFormCellDescriptor
@synthesize value = _value;
@synthesize controllerClass = _controllerClass;
@synthesize controllerStyle = _controllerStyle;
@synthesize block = _initializeBlock;
@synthesize target = _initializeTarget;
@synthesize action = _initializeAction;

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass controllerStyle:(id)theControllerStyle withBlock:(CKFormCellInitializeBlock)initializeBlock{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	self.controllerStyle = theControllerStyle;
	self.block = initializeBlock;
	return self;
}

- (id)initWithValue:(id)theValue controllerClass:(Class)theControllerClass controllerStyle:(id)theControllerStyle target:(id)theTarget action:(SEL)theAction{
	[super init];
	self.value = theValue;
	self.controllerClass = theControllerClass;
	self.controllerStyle = theControllerStyle;
	self.target = theTarget;
	self.action = theAction;
	return self;
}

@end

@implementation CKFormTableViewController
@synthesize sections = _sections;

- (void)postInit{
	self.objectController = [[[CKFormObjectController alloc]init]autorelease];
	self.controllerFactory = [[[CKFormObjectControllerFactory alloc]init]autorelease];
}

- (void)dealloc{
	[_sections release];
	_sections = nil;
	[super dealloc];
}

- (id)initWithSections:(NSArray*)theSections{
	[super init];
	self.sections = [NSMutableArray arrayWithArray:theSections];
	return self;
}

@end
