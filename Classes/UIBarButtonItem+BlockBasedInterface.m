//
//  UIBarButtonItem+BlockBasedInterface.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIBarButtonItem+BlockBasedInterface.h"
#import <objc/runtime.h>
#import "CKBinding.h"
#import "CKBindingsManager.h"

#import "CKDebug.h"

@interface CKUIBarButtonItemBinder : CKBinding {
	//We can use block or target/selector
	UIBarButtonItemExecutionBlock block;
	BOOL binded;
}

@property (nonatomic, copy)   UIBarButtonItemExecutionBlock block;
@property (nonatomic, assign) UIBarButtonItem* barButtonItem;

@end


@interface CKUIBarButtonItemBinder ()
#ifdef ENABLE_WEAK_REF_PROTECTION
@property (nonatomic, retain) CKWeakRef *barButtonItemRef;
#endif
- (void)unbindInstance:(UIBarButtonItem*)instance;
@end


@implementation CKUIBarButtonItemBinder
#ifdef ENABLE_WEAK_REF_PROTECTION
@synthesize barButtonItemRef;
#endif
@synthesize block;

#pragma mark Initialization

-(id)init{
	if (self = [super init]) {
      	binded = NO;
#ifdef ENABLE_WEAK_REF_PROTECTION
        self.barButtonItemRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseBarButtonItemRef:)];
#endif
    }
	return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
#ifdef ENABLE_WEAK_REF_PROTECTION
	self.barButtonItemRef = nil;
#endif
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKUIBarButtonItemBinder : %p>{\barButtonItemRef = %@}",
			self,self.barButtonItem ? [self.barButtonItem description] : @"(null)"];
}

- (void)reset{
    [super reset];
	self.block = nil;
	self.barButtonItem = nil;
}

#ifdef ENABLE_WEAK_REF_PROTECTION
- (id)releaseBarButtonItemRef:(CKWeakRef*)weakRef{
    [self unbindInstance:self.barButtonItem];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setBarButtonItem:(UIBarButtonItem*)theinstance{
	self.barButtonItemRef.object = theinstance;
}

- (UIBarButtonItem*)barButtonItem{
    return self.barButtonItemRef.object;
}
#endif

- (void)execute{
	if(block){
		block();
	}
}

//Update data in model
-(void)buttonClicked{
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(execute) withObject:nil waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(execute) onThread:[NSThread currentThread] withObject:nil waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}

#pragma mark Public API
- (void)bind{
	[self unbind];
    
	if(self.barButtonItem){
        CKAssert(self.barButtonItem.target == nil,@"This button has already been binded or initialized with target action. Unfortunatly, UIBarButtonITem only support 1 target/action");
		self.barButtonItem.target = self;
        self.barButtonItem.action = @selector(buttonClicked);
	}
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:self.barButtonItem];
}

- (void)unbindInstance:(UIBarButtonItem*)theinstance{
	if(binded){
		if(theinstance){
            self.barButtonItem.target = nil;
            self.barButtonItem.action = nil;
		}
		binded = NO;
	}
}

@end






static char UIBarButtonItemUserDataKey;
static char UIBarButtonItemExecutionBlockKey;

@implementation UIBarButtonItem (CKAdditions)
@dynamic block;
@dynamic userData;

- (void)setUserData:(id)userData{
    objc_setAssociatedObject(self, 
                             &UIBarButtonItemUserDataKey,
                             userData,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userData{
    return objc_getAssociatedObject(self, &UIBarButtonItemUserDataKey);
}

- (void)setBlock:(UIBarButtonItemExecutionBlock)block{
    objc_setAssociatedObject(self, 
                             &UIBarButtonItemExecutionBlockKey,
                             block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIBarButtonItemExecutionBlock)block{
    return objc_getAssociatedObject(self, &UIBarButtonItemExecutionBlockKey);
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style block:(void(^)())theblock{
    self = [self initWithImage:image style:style target:self action:@selector(execute:)];
    self.block = theblock;
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style block:(void(^)())theblock{
    self = [self initWithTitle:title style:style target:self action:@selector(execute:)];
    self.block = theblock;
    return self;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem block:(void(^)())theblock{
    self = [self initWithBarButtonSystemItem:systemItem target:self action:@selector(execute:)];
    self.block = theblock;
    return self;
}

- (id)initWithTag:(NSInteger)thetag style:(UIBarButtonItemStyle)style block:(void(^)())theblock{
    self = [self initWithTitle:nil style:style target:self action:@selector(execute:)];
    self.tag = thetag;
    self.block = theblock;
    return self;
}

- (void)bindEventWithBlock:(void(^)())theblock{
    [NSObject validateCurrentBindingsContext];
    
	CKUIBarButtonItemBinder* binder = (CKUIBarButtonItemBinder*)[[CKBindingsManager defaultManager]newDequeuedReusableBindingWithClass:[CKUIBarButtonItemBinder class]];
    binder.contextOptions = [NSObject currentBindingContextOptions];
	[binder setBarButtonItem:self];
	binder.block = theblock;
	[[CKBindingsManager defaultManager]bind:binder withContext:[NSObject currentBindingContext]];
	[binder release];
}

- (void)execute:(id)sender{
    if(self.block != nil){
        self.block();
    }
}

@end
