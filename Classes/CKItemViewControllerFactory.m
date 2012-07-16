//
//  CKItemViewControllerFactory.m
//  CloudKit
//
//  Created by Sebastien Morel.
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

//Private interface
@interface CKItemViewController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) UIViewController* parentController;
@end

@interface CKItemViewControllerFactoryItem() 
@property(nonatomic,retain)NSMutableDictionary* params;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end

/********************************* CKItemViewControllerFactory *********************************
 */

@interface CKItemViewControllerFactory ()
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, assign) id objectController;

- (CKItemViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath;
- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


@implementation CKItemViewControllerFactory
@synthesize items = _items;
@synthesize objectController = _objectController;

- (void)dealloc{
	[_items release];
	_items = nil;
	_objectController = nil;
	[super dealloc];
}

- (id)init{
    self = [super init];
    self.items = [NSMutableArray array];
    return self;
}

+ (CKItemViewControllerFactory*)factory{
    return [[[CKItemViewControllerFactory alloc]init]autorelease];
}

- (void)setItems:(id)theItems{
	NSMutableArray* res = [NSMutableArray array];
	[res mapControllerClass:[CKDocumentCollectionViewCellController class] withObjectClass:[CKDocumentCollection class]];
	[res addObjectsFromArray:theItems];
	
	[_items release];
	_items = [res retain];
}

- (BOOL)doesItem:(CKItemViewControllerFactoryItem*)item matchWithObject:(id)object{
    id filter = [item.params objectForKey:CKItemViewControllerFactoryItemFilter];
	if(filter != nil){
		id filter = [item.params objectForKey:CKItemViewControllerFactoryItemFilter];
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

- (CKItemViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath{
	id object = [_objectController objectAtIndexPath:indexPath];
	for(CKItemViewControllerFactoryItem* item in _items){
		if([self doesItem:item matchWithObject:object]){
			return item;
		}
	}
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
    
    NSAssert([[params parentController] isKindOfClass:[CKItemViewContainerController class]],@"Incompatible parent controller");
    
    CKItemViewContainerController* containerController = (CKItemViewContainerController*)[params parentController];
    CKItemViewController* itemController = [containerController controllerAtIndexPath:indexPath];
    
	NSMutableDictionary* controllerStyle = [itemController controllerStyle];
	if([controllerStyle isEmpty] == NO){
		if([controllerStyle containsObjectForKey:CKStyleCellFlags]){
			return [controllerStyle cellFlags];
		}
	}
    
	id flagsObject = [item.params objectForKey:CKItemViewControllerFactoryItemFlags];
	if(flagsObject != nil){
		if([flagsObject isKindOfClass:[CKCallback class]]){
			CKCallback* flagsCallBack = (CKCallback*)flagsObject;
			if(flagsCallBack != nil){
                [CKItemViewController setupStaticControllerForItem:item inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath forSize:NO];
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
			NSAssert(NO,@"invalid type for controller mappings for key '%@' controllerClass '%@'",CKItemViewControllerFactoryItemFlags,item.controllerClass);
		}
	}
	else{
        [CKItemViewController setupStaticControllerForItem:item inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath forSize:NO];
		Class theClass = item.controllerClass;
        CKItemViewFlags flags = [theClass flagsForObject:object withParams:params];
        return flags;
	}
	return CKItemViewFlagNone;
}

- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath  params:(NSMutableDictionary*)params{
	CKItemViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
    if(!item){
        return CGSizeMake(0,0);
    }
	id object = [_objectController objectAtIndexPath:indexPath];
	[params setObject:object forKey:CKTableViewAttributeObject];
    [params removeObjectForKey:CKTableViewAttributeStaticController];
    
    NSAssert([[params parentController] isKindOfClass:[CKItemViewContainerController class]],@"Incompatible parent controller");
    
    CKItemViewContainerController* containerController = (CKItemViewContainerController*)[params parentController];
    CKItemViewController* itemController = [containerController controllerAtIndexPath:indexPath];
    
	NSMutableDictionary* controllerStyle = [itemController controllerStyle];
	if([controllerStyle isEmpty] == NO){
		if([controllerStyle containsObjectForKey:CKStyleCellSize]){
			return [controllerStyle cellSize];
		}
	}
    
	id sizeObject = [item.params objectForKey:CKItemViewControllerFactoryItemSize];
	if(sizeObject != nil){
		if([sizeObject isKindOfClass:[CKCallback class]]){
			CKCallback* sizeCallBack = (CKCallback*)sizeObject;
			if(sizeCallBack != nil){
                [CKItemViewController setupStaticControllerForItem:item inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath forSize:YES];
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
			NSAssert(NO,@"invalid type for controller mappings for key '%@' controllerClass '%@'",CKItemViewControllerFactoryItemFlags,item.controllerClass);
		}
	}
	else{
        [CKItemViewController setupStaticControllerForItem:item inParams:params withStyle:controllerStyle withObject:object withIndexPath:indexPath  forSize:YES];
		Class theClass = item.controllerClass;
        NSValue* v = (NSValue*) [theClass performSelector:@selector(viewSizeForObject:withParams:) withObject:object withObject:params];
        CGSize size = [v CGSizeValue];
        return size;
	}
	return CGSizeMake(100,44);
}

- (CKItemViewControllerFactoryItem*)addItem:(CKItemViewControllerFactoryItem*)item{
    [self.items addObject:item];
	return item;
}

- (CKItemViewControllerFactoryItem*)addItemForObjectOfClass:(Class)type withControllerOfClass:(Class)controllerClass{
    return [self addItemForObjectWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:type];
    }] withControllerOfClass:controllerClass];
}

- (CKItemViewControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate withControllerOfClass:(Class)controllerClass{
    CKItemViewControllerFactoryItem* item = [[[CKItemViewControllerFactoryItem alloc]init]autorelease];
	item.controllerClass = controllerClass;
	item.params = [NSMutableDictionary dictionaryWithObject:predicate 
                                                     forKey:CKItemViewControllerFactoryItemFilter];
	[self.items addObject:item];
	return item;
}

- (CKItemViewControllerFactoryItem*)addItemForObjectOfClass:(Class)type withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKItemViewControllerFactoryItem* item = [CKItemViewControllerFactoryItem itemForObjectOfClass:type withControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}


- (CKItemViewControllerFactoryItem*)addItemForObjectWithPredicate:(NSPredicate*)predicate withControllerCreationBlock:(CKItemViewController*(^)(id object, NSIndexPath* indexPath))block{
    CKItemViewControllerFactoryItem* item = [CKItemViewControllerFactoryItem itemForObjectWithPredicate:predicate withControllerCreationBlock:block];
    [self.items addObject:item];
    return item;
}

@end



/********************************* DEPRECATED *********************************
 */

@implementation CKObjectViewControllerFactory
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
	factory.items = [NSMutableArray arrayWithArray:mappings];
	return factory;
}

@end
