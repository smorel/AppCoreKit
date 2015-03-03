//
//  CKCollectionBlockBinder.m
//  AppCoreKit
//
//  Created by Martin Dufort on 12-09-13.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKCollectionBlockBinder.h"

#import "NSObject+Runtime.h"
#import "CKBindingsManager.h"
#import "CKCollectionController.h"

@interface CKCollectionBlockBinder () <CKObjectControllerDelegate>
@property(nonatomic,retain) CKCollectionController* collectionController;
#ifdef ENABLE_WEAK_REF_PROTECTION
@property (nonatomic, retain) CKWeakRef *instanceRef;
#endif
- (void)unbindInstance:(id)instance;
@end

@implementation CKCollectionBlockBinder{
	BOOL binded;
}

@synthesize events, instance,block,collectionController;

#ifdef ENABLE_WEAK_REF_PROTECTION
@synthesize instanceRef;
#endif

-(id)init{
    if (self = [super init]) {
        binded = NO;
        self.events = CKCollectionBindingEventAll;
#ifdef ENABLE_WEAK_REF_PROTECTION
        self.instanceRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance:)];
#endif
    }
    return self;
}

-(void)dealloc{
	[self unbind];
	[self reset];
#ifdef ENABLE_WEAK_REF_PROTECTION
	self.instanceRef = nil;
#endif
	[super dealloc];
}

- (void)reset{
    [super reset];
	self.events = CKCollectionBindingEventAll;
	self.block = nil;
	self.instance = nil;
    self.collectionController = nil;
}

#ifdef ENABLE_WEAK_REF_PROTECTION
- (id)releaseInstance:(CKWeakRef*)weakRef{
    [self unbindInstance:self.instance];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setInstance:(CKCollection*)theinstance{
	self.instanceRef.object = theinstance;
}

- (CKCollection*)instance{
    return self.instanceRef.object;
}

#endif

- (void)bind{
	[self unbind];
    
	if(self.instance){
		self.collectionController = [CKCollectionController controllerWithCollection:self.instance];
        self.collectionController.delegate = self;
	}
	binded = YES;
}

-(void)unbind{
	if(self.collectionController){
        self.collectionController.delegate = nil;
        self.collectionController = nil;
    }
}

- (void)unbindInstance:(id)theinstance{
	if(binded){
		if(self.collectionController){
            self.collectionController.delegate = nil;
            self.collectionController = nil;
        }
		binded = NO;
	}
}

-(void)sendEvent:(CKCollectionBindingEvents)event withObjects:(NSArray*)objects indexes:(NSIndexSet*)indexes{
    if((self.events & event) && self.block){
        NSArray* params = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:event],
                           objects,
                           indexes,
                           nil];
        
        if(self.contextOptions & CKBindingsContextPerformOnMainThread){
            [self performSelectorOnMainThread:@selector(execute:) withObject:params waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
        }
        else {
            [self performSelector:@selector(execute:) onThread:[NSThread currentThread] withObject:params waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
        }
    }
}

- (void)execute:(NSArray*)params{
    CKCollectionBindingEvents event = [[params objectAtIndex:0]integerValue];
    NSArray* objects = [params objectAtIndex:1];
    NSIndexSet* indexes = [params objectAtIndex:2];
    self.block(event,objects,indexes);
}

+ (NSIndexSet*)indexSetFromIndexPaths:(NSArray*)indexPaths{
    NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
    for(NSIndexPath* indexPath in indexPaths){
        [indexes addIndex:[indexPath row]];
    }
    return indexes;
}

- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    [self sendEvent:CKCollectionBindingEventInsertion withObjects:objects indexes:[[self class]indexSetFromIndexPaths:indexPaths]];
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    [self sendEvent:CKCollectionBindingEventRemoval withObjects:objects indexes:[[self class]indexSetFromIndexPaths:indexPaths]];
}

@end
