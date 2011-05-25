//
//  CKItemViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController.h"
#import "CKTableViewCellController+Style.h"

#import "CKStyleManager.h"
#import <CloudKit/CKNSObject+Bindings.h>

@implementation CKItemViewController

@synthesize name = _name;
@synthesize value = _value;
@synthesize indexPath = _indexPath;
@synthesize parentController = _parentController;
@synthesize view = _view;
@synthesize target = _target;
@synthesize action = _action;
@synthesize accessoryAction = _accessoryAction;
@synthesize initCallback = _initCallback;
@synthesize setupCallback = _setupCallback;
@synthesize selectionCallback = _selectionCallback;
@synthesize accessorySelectionCallback = _accessorySelectionCallback;

- (void)dealloc {
	[self clearBindingsContext];
	
	[_value release];
	[_indexPath release];
	[_target release];
	[_name release];
	
	[_accessorySelectionCallback release];
	[_initCallback release];
	[_setupCallback release];
	[_selectionCallback release];
	
	_target = nil;
	_action = nil;
	_accessoryAction = nil;
	_parentController = nil;
	[super dealloc];
}

//sequence : loadView, initView, applyStyle
//when reusing : setupView

- (UIView *)loadView{
	NSAssert(NO,@"To implement in subclass");
	return nil;
}

- (void)applyStyle{
	[self applyStyle:[self controllerStyle] forView:self.view];
}

- (void)setupView:(UIView *)view{
	if(_setupCallback != nil){
		[_setupCallback execute:self];
	}
	//To implement in subclass
}

- (void)initView:(UIView*)view{
	if(_initCallback != nil){
		[_initCallback execute:self];
	}
}

- (void)rotateView:(UIView*)view withParams:(NSDictionary*)params animated:(BOOL)animated{
	//To implement in subclass
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagAll;
}

- (void)viewDidAppear:(UIView *)view{
}

- (void)viewDidDisappear{
}

- (NSIndexPath *)willSelect{
	return self.indexPath;
}

- (void)didSelect{
	if (_target && [_target respondsToSelector:_action]) {
		[_target performSelector:_action withObject:self];
	}
	if(_selectionCallback != nil){
		[_selectionCallback execute:self];
	}
}

- (void)didSelectAccessoryView{
	if (_target && [_target respondsToSelector:_accessoryAction]) {
		[_target performSelector:_accessoryAction withObject:self];
	}
	if(_accessorySelectionCallback != nil){
		[_accessorySelectionCallback execute:self];
	}
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	// This method is hidden from the public interface and is called by the parent controller
	// when adding the CKTableViewCellController.	
	[_indexPath release];
	_indexPath = [indexPath retain];
}

- (void)setParentController:(UIViewController *)parentController {
	// Set a *weak* reference to the parent controller
	// This method is hidden from the public interface and is called by the parent controller
	// when adding the CKTableViewCellController.
	_parentController = parentController;
}

- (NSString *)identifier {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>",[[self class] description],controllerStyle];
}

@end

