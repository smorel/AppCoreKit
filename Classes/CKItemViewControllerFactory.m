//
//  CKItemViewControllerFactory.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewControllerFactory.h"
#import "CKObjectController.h"
#import "CKDocumentCollectionCellController.h"
#import "CKDocumentCollection.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "CKTableViewCellController+Style.h"
#import "CKItemViewController+DynamicLayout.h"
#import "CKNSDictionary+TableViewAttributes.h"

@interface CKItemViewController()
@property (nonatomic, retain, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) UIViewController* parentController;
@end


/********************************* CKItemViewControllerFactory *********************************
 */

@interface CKItemViewControllerFactory ()
@property (nonatomic, retain) NSMutableArray* mappings;
@property (nonatomic, assign) id objectController;
@end


@implementation CKItemViewControllerFactory
@synthesize mappings = _mappings;
@synthesize objectController = _objectController;

- (void)dealloc{
	[_mappings release];
	_mappings = nil;
	_objectController = nil;
	[super dealloc];
}

- (void)setMappings:(id)theMappings{
	NSMutableArray* res = [NSMutableArray array];
	[res mapControllerClass:[CKDocumentCollectionViewCellController class] withObjectClass:[CKDocumentCollection class]];
	[res addObjectsFromArray:theMappings];
	
	[_mappings release];
	_mappings = [res retain];
}

- (CKItemViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath{
	id object = [_objectController objectAtIndexPath:indexPath];
	for(CKItemViewControllerFactoryItem* item in _mappings){
		if([item matchWithObject:object]){
			return item;
		}
	}
	NSAssert(NO,@"controller factory could not find matching item for object '%@'",object);
	return nil;
}


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	CKItemViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
    if(!item){
        return nil;
    }
	return [item controllerForObject:object atIndexPath:indexPath];
}

- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params{
	CKItemViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
    if(!item){
        return CKItemViewFlagNone;
    }
	id object = [_objectController objectAtIndexPath:indexPath];
	[params setObject:object forKey:CKTableViewAttributeObject];
	return [item flagsForObject:object atIndexPath:indexPath withParams:params];
}

- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath  params:(NSMutableDictionary*)params{
	CKItemViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
    if(!item){
        return CGSizeMake(0,0);
    }
	id object = [_objectController objectAtIndexPath:indexPath];
	[params setObject:object forKey:CKTableViewAttributeObject];
	return [item sizeForObject:object atIndexPath:indexPath withParams:params];
}

@end

/********************************* CKItemViewControllerFactoryItem *********************************
 */

NSString* CKItemViewControllerFactoryItemCreate               = @"CKItemViewControllerFactoryItemCreate";
NSString* CKItemViewControllerFactoryItemInit                 = @"CKItemViewControllerFactoryItemInit";
NSString* CKItemViewControllerFactoryItemSetup                = @"CKItemViewControllerFactoryItemSetup";
NSString* CKItemViewControllerFactoryItemSelection            = @"CKItemViewControllerFactoryItemSelection";
NSString* CKItemViewControllerFactoryItemAccessorySelection   = @"CKItemViewControllerFactoryItemAccessorySelection";
NSString* CKItemViewControllerFactoryItemFlags                = @"CKItemViewControllerFactoryItemFlags";
NSString* CKItemViewControllerFactoryItemFilter               = @"CKItemViewControllerFactoryItemFilter";
NSString* CKItemViewControllerFactoryItemSize                 = @"CKItemViewControllerFactoryItemSize";
NSString* CKItemViewControllerFactoryItemBecomeFirstResponder = @"CKItemViewControllerFactoryItemBecomeFirstResponder";
NSString* CKItemViewControllerFactoryItemResignFirstResponder = @"CKItemViewControllerFactoryItemResignFirstResponder";
NSString* CKItemViewControllerFactoryItemLayout               = @"CKItemViewControllerFactoryItemLayout";

@interface CKItemViewControllerFactoryItem() 
@property(nonatomic,retain)NSMutableDictionary* params;
@end

@implementation CKItemViewControllerFactoryItem
@synthesize controllerClass = _controllerClass;
@synthesize params = _params;

- (id)init{
	[super init];
	self.params = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	[_params release];
	_params = nil;
	_controllerClass = nil;
	[super dealloc];
}

- (BOOL)matchWithObject:(id)object{
	id filter = [_params objectForKey:CKItemViewControllerFactoryItemFilter];
	if(filter != nil){
		id filter = [_params objectForKey:CKItemViewControllerFactoryItemFilter];
		if([filter isKindOfClass:[CKCallback class]]){
			CKCallback* callback = (CKCallback*)filter;
			id returnValue = [callback execute:object];
			NSAssert([returnValue isKindOfClass:[NSNumber class]],@"filter callback should return BOOL as an NSNumber");
			NSNumber* number = (NSNumber*)returnValue;
			return [number boolValue];
		}
		else if([filter isKindOfClass:[NSPredicate class]]){
			NSPredicate* predicate = (NSPredicate*)filter;
			return [predicate evaluateWithObject:object];
		}
	}
	return NO;
}

- (CKCallback*)createCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemCreate];
}

- (CKCallback*)initCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemInit];
}

- (CKCallback*)setupCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemSetup];
}

- (CKCallback*)selectionCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemSelection];
}

- (CKCallback*)accessorySelectionCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemAccessorySelection];
}

- (CKCallback*)becomeFirstResponderCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemBecomeFirstResponder];
}

- (CKCallback*)resignFirstResponderCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemResignFirstResponder];
}

- (CKCallback*)layoutCallback{
	return [_params objectForKey:CKItemViewControllerFactoryItemLayout];
}

- (CKItemViewFlags)flagsForObject:(id)object atIndexPath:(NSIndexPath*)indexPath  withParams:(NSMutableDictionary*)params{
	//Style size first
    NSAssert([[params parentController] isKindOfClass:[CKItemViewContainerController class]],@"Incompatible parent controller");
    
    CKItemViewContainerController* containerController = (CKItemViewContainerController*)[params parentController];
    CKItemViewController* itemController = [containerController controllerAtIndexPath:indexPath];
    
	NSMutableDictionary* controllerStyle = [itemController controllerStyle];
	if([controllerStyle isEmpty] == NO){
		if([controllerStyle containsObjectForKey:CKStyleCellFlags]){
			return [controllerStyle cellFlags];
		}
	}
    
	id flagsObject = [_params objectForKey:CKItemViewControllerFactoryItemFlags];
	if(flagsObject != nil){
		if([flagsObject isKindOfClass:[CKCallback class]]){
			CKCallback* flagsCallBack = (CKCallback*)flagsObject;
			if(flagsCallBack != nil){
                [CKItemViewController setupStaticControllerForItem:self inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath forSize:NO];
				NSNumber* number = [flagsCallBack execute:params];
				CKItemViewFlags flags = (CKItemViewFlags)[number intValue];
				return flags;
			}
		}
		else if([flagsObject isKindOfClass:[NSNumber class]]){
			NSNumber* number = (NSNumber*)flagsObject;
			CKItemViewFlags flags = (CKItemViewFlags)[number intValue];
			return flags;
		}
		else{
			NSAssert(NO,@"invalid type for controller mappings for key '%@' controllerClass '%@'",CKItemViewControllerFactoryItemFlags,self.controllerClass);
		}
	}
	else{
        [CKItemViewController setupStaticControllerForItem:self inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath forSize:NO];
		Class theClass = self.controllerClass;
        CKItemViewFlags flags = [theClass flagsForObject:object withParams:params];
        return flags;
	}
	return CKItemViewFlagNone;
}


- (CGSize)sizeForObject:(id)object atIndexPath:(NSIndexPath*)indexPath withParams:(NSMutableDictionary*)params{
	//Style size first
    NSAssert([[params parentController] isKindOfClass:[CKItemViewContainerController class]],@"Incompatible parent controller");
    
    CKItemViewContainerController* containerController = (CKItemViewContainerController*)[params parentController];
    CKItemViewController* itemController = [containerController controllerAtIndexPath:indexPath];
    
	NSMutableDictionary* controllerStyle = [itemController controllerStyle];
	if([controllerStyle isEmpty] == NO){
		if([controllerStyle containsObjectForKey:CKStyleCellSize]){
			return [controllerStyle cellSize];
		}
	}
    
	id sizeObject = [_params objectForKey:CKItemViewControllerFactoryItemSize];
	if(sizeObject != nil){
		if([sizeObject isKindOfClass:[CKCallback class]]){
			CKCallback* sizeCallBack = (CKCallback*)sizeObject;
			if(sizeCallBack != nil){
                [CKItemViewController setupStaticControllerForItem:self inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath forSize:YES];
				NSValue* value = [sizeCallBack execute:params];
				CGSize size = [value CGSizeValue];
				return size;
			}
		}
		else if([sizeObject isKindOfClass:[NSValue class]]){
			NSValue* value = (NSValue*)sizeObject;
			CGSize size = [value CGSizeValue];
			return size;
		}
		else{
			NSAssert(NO,@"invalid type for controller mappings for key '%@' controllerClass '%@'",CKItemViewControllerFactoryItemFlags,self.controllerClass);
		}
	}
	else{
        [CKItemViewController setupStaticControllerForItem:self inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath  forSize:YES];
		Class theClass = self.controllerClass;
        NSValue* v = (NSValue*) [theClass performSelector:@selector(viewSizeForObject:withParams:) withObject:object withObject:params];
        CGSize size = [v CGSizeValue];
        return size;
	}
	return CGSizeMake(100,44);
}

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	CKItemViewController* controller = [[[self.controllerClass alloc]init]autorelease];
    controller.createCallback = [self createCallback];
	controller.initCallback = [self initCallback];
	controller.setupCallback = [self setupCallback];
	controller.selectionCallback = [self selectionCallback];
	controller.accessorySelectionCallback = [self accessorySelectionCallback];
	controller.becomeFirstResponderCallback = [self becomeFirstResponderCallback];
	controller.resignFirstResponderCallback = [self resignFirstResponderCallback];
	controller.layoutCallback = [self layoutCallback];
	
	[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	[controller setValue:object];
	
	id createObject = [_params objectForKey:CKItemViewControllerFactoryItemCreate];
	if(createObject != nil && [createObject isKindOfClass:[CKCallback class]]){
		CKCallback* createCallBack = (CKCallback*)createObject;
		[createCallBack execute:controller];
	}
	
	return controller;
}

- (void)setCreateBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemCreate];
}

- (void)setInitBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemInit];
}

- (void)setSetupBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemSetup];
}

- (void)setSelectionBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemSelection];
}

- (void)setAccessorySelectionBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemAccessorySelection];
}

- (void)setFlagsBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemFlags];
}

- (void)setFilterBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemFilter];
}

- (void)setSizeBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemSize];
}

- (void)setBecomeFirstResponderBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemBecomeFirstResponder];
}

- (void)setResignFirstResponderBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemResignFirstResponder];
}

- (void)setLayoutBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKItemViewControllerFactoryItemLayout];
}

- (void)setCreateTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemCreate];
}

- (void)setInitTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemInit];
}

- (void)setSetupTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemSetup];
}

- (void)setSelectionTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemSelection];
}

- (void)setAccessorySelectionTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemAccessorySelection];
}

- (void)setFlagsTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemFlags];
}

- (void)setFilterTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemFilter];
}

- (void)setSizeTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemSize];
}

- (void)setBecomeFirstResponderTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemBecomeFirstResponder];
}

- (void)setResignFirstResponderTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemResignFirstResponder];
}

- (void)setLayoutTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKItemViewControllerFactoryItemLayout];
}

- (void)setFlags:(CKItemViewFlags)flags{
	[self.params setObject:[NSNumber numberWithInt:flags] forKey:CKItemViewControllerFactoryItemFlags];
}

- (void)setFilterPredicate:(NSPredicate*)predicate{
	[self.params setObject:predicate forKey:CKItemViewControllerFactoryItemFilter];
}

- (void)setSize:(CGSize)size{
	[self.params setObject:[NSValue valueWithCGSize:size] forKey:CKItemViewControllerFactoryItemSize];
}

@end




/********************************* DEPRECATED *********************************
 */

@implementation CKObjectViewControllerFactory
@end

@implementation CKObjectViewControllerFactoryItem
@end

@implementation NSMutableArray (CKObjectViewControllerFactory_DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)


- (CKItemViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withParams:(NSMutableDictionary*)params{
	CKItemViewControllerFactoryItem* item = [[[CKItemViewControllerFactoryItem alloc]init]autorelease];
	item.controllerClass = controllerClass;
	item.params = params;
	[self addObject:item];
	return item;
}

- (CKItemViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withObjectClass:(Class)objectClass{
	return [self mapControllerClass:controllerClass withParams:[NSMutableDictionary dictionaryWithObject:
														 [CKCallback callbackWithBlock:^(id object){return (id)[NSNumber numberWithBool:[object isKindOfClass:objectClass]];}] 
																					forKey:CKItemViewControllerFactoryItemFilter]];
}

@end



@implementation CKItemViewControllerFactory(DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)

+ (CKItemViewControllerFactory*)factoryWithMappings:(NSArray*)mappings {
	return [CKItemViewControllerFactory factoryWithMappings:mappings withFactoryClass:[CKItemViewControllerFactory class]];
}

+ (id)factoryWithMappings:(NSArray*)mappings withFactoryClass:(Class)type{
	CKItemViewControllerFactory* factory = (CKItemViewControllerFactory*)[[[type alloc]init]autorelease];
	factory.mappings = [NSMutableArray arrayWithArray:mappings];
	return factory;
}

@end
