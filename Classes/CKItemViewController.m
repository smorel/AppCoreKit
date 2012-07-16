//
//  CKItemViewController.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController.h"
#import "CKTableViewCellController+Style.h"

#import "CKStyleManager.h"
#import "CKNSObject+Bindings.h"
#import "CKDebug.h"

@interface CKItemViewController()
@property (nonatomic, retain) CKWeakRef *viewRef;
@property (nonatomic, retain) CKWeakRef *weakParentController;
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, retain) CKWeakRef *targetRef;
@end


@implementation CKItemViewController

@synthesize name = _name;
@synthesize value = _value;
@synthesize indexPath = _indexPath;
@synthesize parentController = _parentController;
@synthesize view = _view;
@synthesize target = _target;
@synthesize action = _action;
@synthesize accessoryAction = _accessoryAction;
@synthesize createCallback = _createCallback;
@synthesize initCallback = _initCallback;
@synthesize setupCallback = _setupCallback;
@synthesize selectionCallback = _selectionCallback;
@synthesize accessorySelectionCallback = _accessorySelectionCallback;
@synthesize becomeFirstResponderCallback = _becomeFirstResponderCallback;
@synthesize resignFirstResponderCallback = _resignFirstResponderCallback;
@synthesize layoutCallback = _layoutCallback;
@synthesize viewRef = _viewRef;
@synthesize weakParentController = _weakParentController;
@synthesize viewDidAppearCallback = _viewDidAppearCallback;
@synthesize viewDidDisappearCallback = _viewDidDisappearCallback;
@synthesize targetRef = _targetRef;

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
	[_becomeFirstResponderCallback release];
	[_resignFirstResponderCallback release];
	[_createCallback release];
	[_layoutCallback release];
	[_viewRef release];
	[_weakParentController release];
	[_viewDidAppearCallback release];
	[_viewDidDisappearCallback release];
	[_targetRef release];
	
	_action = nil;
	_accessoryAction = nil;
	_parentController = nil;
	[super dealloc];
}

- (void)setView:(UIView *)view{
	self.viewRef = [CKWeakRef weakRefWithObject:view];
}

- (UIView*)view{
	return [_viewRef object];
}

- (void)setParentController:(UIViewController *)c{
	self.weakParentController = [CKWeakRef weakRefWithObject:c];
}

- (UIViewController*)parentController{
	return (UIViewController*)[_weakParentController object];
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
    if(_viewDidAppearCallback){
        [_viewDidAppearCallback execute:self];
    }
}

- (void)viewDidDisappear{
    if(_viewDidDisappearCallback){
        [_viewDidDisappearCallback execute:self];
    }
}

- (NSIndexPath *)willSelect{
	return self.indexPath;
}

- (void)setTarget:(id)target{
    if(!_targetRef){
        self.targetRef = [CKWeakRef weakRefWithObject:target];
    }
    else{
        _targetRef.object = target;
    }
}

- (id)target{
    return [_targetRef object];
}

- (void)didSelect{
	if ([_targetRef object] && [[_targetRef object] respondsToSelector:_action]) {
		[[_targetRef object] performSelector:_action withObject:self];
	}
	if(_selectionCallback != nil){
		[_selectionCallback execute:self];
	}
}

- (void)didSelectAccessoryView{
	if ([_targetRef object] && [[_targetRef object] respondsToSelector:_accessoryAction]) {
		[[_targetRef object] performSelector:_accessoryAction withObject:self];
	}
	if(_accessorySelectionCallback != nil){
		[_accessorySelectionCallback execute:self];
	}
}

- (NSString *)identifier {
    if(_createCallback){
        [_createCallback execute:self];
    }
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>",[[self class] description],controllerStyle];
}

- (void)didBecomeFirstResponder{
	if(_becomeFirstResponderCallback != nil){
		[_becomeFirstResponderCallback execute:self];
	}
}

- (void)didResignFirstResponder{
	if(_resignFirstResponderCallback != nil){
		[_resignFirstResponderCallback execute:self];
	}
}


- (void)setIndexPath:(NSIndexPath*)theindexPath{
    [_indexPath release];
    _indexPath = [[NSIndexPath indexPathForRow:[theindexPath row] inSection:[theindexPath section]]retain];
}

@end

