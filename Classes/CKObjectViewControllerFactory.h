//
//  CKFeedViewControllerFactory.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSDictionary+TableViewAttributes.h"
#import "CKTableViewCellController.h"


extern NSString* CKObjectViewControllerFactoryItemCreate;
extern NSString* CKObjectViewControllerFactoryItemInit;
extern NSString* CKObjectViewControllerFactoryItemSetup;
extern NSString* CKObjectViewControllerFactoryItemSelection;
extern NSString* CKObjectViewControllerFactoryItemAccessorySelection;
extern NSString* CKObjectViewControllerFactoryItemFlags;
extern NSString* CKObjectViewControllerFactoryItemFilter;
extern NSString* CKObjectViewControllerFactoryItemSize;

@interface CKObjectViewControllerFactoryItem : NSObject{
	Class _controllerClass;
	NSMutableDictionary* _params;
}
@property(nonatomic,assign)Class controllerClass;
@property(nonatomic,retain)NSMutableDictionary* params;

- (BOOL)matchWithObject:(id)object;
- (CKTableViewCellFlags)flagsForObject:(id)object atIndexPath:(NSIndexPath*)indexPath  withParams:(NSMutableDictionary*)params;
- (CGSize)sizeForObject:(id)object atIndexPath:(NSIndexPath*)indexPath  withParams:(NSMutableDictionary*)params;

- (CKCallback*)initCallback;
- (CKCallback*)setupCallback;
- (CKCallback*)selectionCallback;
- (CKCallback*)accessorySelectionCallback;

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


//revoir cette interface et comment elle est utilisee ds les objectTableViewController et Carousel pour qu'ils utilisent directement des CKObjectViewControllerFactoryItem
@interface CKObjectViewControllerFactory : NSObject {
	NSMutableArray* _mappings;
	id _objectController;
}

@property (nonatomic, retain, readonly) NSMutableArray* mappings;
@property (nonatomic, assign, readonly) id objectController;

//construction helpers
+ (CKObjectViewControllerFactory*)factoryWithMappings:(NSArray*)mappings;
+ (id)factoryWithMappings:(NSArray*)mappings withFactoryClass:(Class)type;

//Parent controller API
- (CKObjectViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath;
- (CKTableViewCellFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


//helpers to create CKObjectViewControllerFactoryItem in self
@interface NSMutableArray (CKObjectViewControllerFactory)

//low level API
- (void)mapControllerClass:(Class)controllerClass withParams:(NSMutableDictionary*)params;

//Higher level API
- (void)mapControllerClass:(Class)controllerClass withObjectClass:(Class)objectClass;

@end