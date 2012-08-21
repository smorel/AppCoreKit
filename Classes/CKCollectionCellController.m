//
//  CKCollectionCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollectionCellController.h"
#import "CKCollectionViewController.h"
#import "CKTableViewCellController+Style.h"

#import "CKStyleManager.h"
#import "NSObject+Bindings.h"
#import "CKDebug.h"

@interface CKCollectionCellController()
@property (nonatomic, retain) CKWeakRef *viewRef;
@property (nonatomic, retain) CKWeakRef *weakParentController;
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, retain) CKWeakRef *targetRef;
@property (nonatomic, assign, readwrite) CKCollectionViewController* containerController;
@property (nonatomic, assign) BOOL isViewAppeared;
@end


@implementation CKCollectionCellController

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
@synthesize isViewAppeared = _isViewAppeared;
@synthesize deallocCallback = _deallocCallback;

@synthesize flags = _flags;
@synthesize size = _size;

- (void)dealloc {
    if(_deallocCallback){
        [_deallocCallback execute:self];
    }
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
    [_deallocCallback release];
	
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
    _flags = CKItemViewFlagAll;
    _size = CGSizeMake(320,44);
    _isViewAppeared = NO;
}

- (void)flagsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKItemViewFlags",
                                                 CKItemViewFlagNone,
                                                 CKItemViewFlagSelectable,
                                                 CKItemViewFlagEditable,
                                                 CKItemViewFlagRemovable,
                                                 CKItemViewFlagMovable,
                                                 CKItemViewFlagAll,
                                                 CKTableViewCellFlagNone,
                                                 CKTableViewCellFlagSelectable,
                                                 CKTableViewCellFlagEditable,
                                                 CKTableViewCellFlagRemovable,
                                                 CKTableViewCellFlagMovable,
                                                 CKTableViewCellFlagAll);
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
        [self.containerController updateSizeForControllerAtIndexPath:self.indexPath];
    }
    [self didChangeValueForKey:@"size"];
}

//this will tell the controller it needs to update by computing a new size.
- (void)invalidateSize{
    if(self.containerController){
        [self.containerController updateSizeForControllerAtIndexPath:self.indexPath];
    }
}

- (void)setView:(UIView *)view{
    if(_viewRef){
        [_viewRef setObject:view];
    }else{
        self.viewRef = [CKWeakRef weakRefWithObject:view];
    }
}

- (UIView*)view{
	return [_viewRef object];
}

- (void)setContainerController:(CKCollectionViewController *)c{
    if(_weakParentController){
        [_weakParentController setObject:c];
    }else{
        self.weakParentController = [CKWeakRef weakRefWithObject:c];
    }
}

- (CKCollectionViewController*)containerController{
	return (CKCollectionViewController*)[_weakParentController object];
}

//sequence : loadView, initView, applyStyle
//when reusing : setupView

- (UIView *)loadView{
	CKAssert(NO,@"To implement in subclass");
	return nil;
}

- (void)applyStyle{
    if([[CKStyleManager defaultManager]isEmpty])
        return;
    
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
    
	[self applyStyle];
}

- (void)rotateView:(UIView*)view animated:(BOOL)animated{
	//To implement in subclass
}

- (void)viewDidAppear:(UIView *)view{
    if(!self.isViewAppeared){
        if(_viewDidAppearCallback){
            [_viewDidAppearCallback execute:self];
        }
        self.isViewAppeared = YES;
    }
}

- (void)viewDidDisappear{
    if(self.isViewAppeared){
        if(_viewDidDisappearCallback){
            [_viewDidDisappearCallback execute:self];
        }
        self.isViewAppeared = YES;
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

- (NSMutableDictionary*)stylesheet{
    return [self controllerStyle];
}

@end

