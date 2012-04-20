//
//  CKItemViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController.h"
#import "CKItemViewContainerController.h"
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
@synthesize containerController = _containerController;
@synthesize view = _view;
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

@synthesize flags;
@synthesize size = _size;

- (void)dealloc {
	[self clearBindingsContext];
	
	[_value release];
	[_indexPath release];
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
	
	_containerController = nil;
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

- (void)postInit{
    self.flags = CKItemViewFlagAll;
    self.size = CGSizeMake(320,44);
}

- (void)setSize:(CGSize)s{
    [self setSize:s notifyingContainerForUpdate:YES];
}

- (void)setSize:(CGSize)s notifyingContainerForUpdate:(BOOL)notifyingContainerForUpdate{
    if(CGSizeEqualToSize(_size, s))
        return;
    
    [self willChangeValueForKey:@"size"];
    _size = s;
    //this will tell the controller it needs to update without computing a new size.
    if(notifyingContainerForUpdate && self.containerController){
        [self.containerController onSizeChangeAtIndexPath:self.indexPath];
    }
    [self didChangeValueForKey:@"size"];
}

//this will tell the controller it needs to update by computing a new size.
- (void)invalidateSize{
    if(self.containerController){
        [self.containerController onSizeChangeAtIndexPath:self.indexPath];
    }
}

- (void)setView:(UIView *)view{
	self.viewRef = [CKWeakRef weakRefWithObject:view];
}

- (UIView*)view{
	return [_viewRef object];
}

- (void)setContainerController:(CKItemViewContainerController *)c{
	self.weakParentController = [CKWeakRef weakRefWithObject:c];
}

- (CKItemViewContainerController*)containerController{
	return (CKItemViewContainerController*)[_weakParentController object];
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

- (void)rotateView:(UIView*)view animated:(BOOL)animated{
	//To implement in subclass
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
	if(_selectionCallback != nil){
		[_selectionCallback execute:self];
	}
}

- (void)didSelectAccessoryView{
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

