//
//  CKFeedViewControllerFactory.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSDictionary+TableViewAttributes.h"
#import "CKItemViewController.h"


extern NSString* CKObjectViewControllerFactoryItemCreate;
extern NSString* CKObjectViewControllerFactoryItemInit;
extern NSString* CKObjectViewControllerFactoryItemSetup;
extern NSString* CKObjectViewControllerFactoryItemSelection;
extern NSString* CKObjectViewControllerFactoryItemAccessorySelection;
extern NSString* CKObjectViewControllerFactoryItemBecomeFirstResponder;
extern NSString* CKObjectViewControllerFactoryItemResignFirstResponder;
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
- (CKItemViewFlags)flagsForObject:(id)object atIndexPath:(NSIndexPath*)indexPath  withParams:(NSMutableDictionary*)params;
- (CGSize)sizeForObject:(id)object atIndexPath:(NSIndexPath*)indexPath  withParams:(NSMutableDictionary*)params;

- (CKCallback*)createCallback;
- (CKCallback*)initCallback;
- (CKCallback*)setupCallback;
- (CKCallback*)selectionCallback;
- (CKCallback*)accessorySelectionCallback;
- (CKCallback*)becomeFirstResponderCallback;
- (CKCallback*)resignFirstResponderCallback;

- (void)setCreateBlock:(CKCallbackBlock)block;
- (void)setInitBlock:(CKCallbackBlock)block;
- (void)setSetupBlock:(CKCallbackBlock)block;
- (void)setSelectionBlock:(CKCallbackBlock)block;
- (void)setAccessorySelectionBlock:(CKCallbackBlock)block;
- (void)setFlagsBlock:(CKCallbackBlock)block;
- (void)setFilterBlock:(CKCallbackBlock)block;
- (void)setSizeBlock:(CKCallbackBlock)block;
- (void)setBecomeFirstResponderBlock:(CKCallbackBlock)block;
- (void)setResignFirstResponderBlock:(CKCallbackBlock)block;


- (void)setCreateTarget:(id)target action:(SEL)action;
- (void)setInitTarget:(id)target action:(SEL)action;
- (void)setSetupTarget:(id)target action:(SEL)action;
- (void)setSelectionTarget:(id)target action:(SEL)action;
- (void)setAccessorySelectionTarget:(id)target action:(SEL)action;
- (void)setFlagsTarget:(id)target action:(SEL)action;
- (void)setFilterTarget:(id)target action:(SEL)action;
- (void)setSizeTarget:(id)target action:(SEL)action;
- (void)setBecomeFirstResponderTarget:(id)target action:(SEL)action;
- (void)setResignFirstResponderTarget:(id)target action:(SEL)action;

- (void)setFlags:(CKItemViewFlags)flags;
- (void)setFilterPredicate:(NSPredicate*)predicate;
- (void)setSize:(CGSize)size;

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
- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


//helpers to create CKObjectViewControllerFactoryItem in self
@interface NSMutableArray (CKObjectViewControllerFactory)

//low level API
- (CKObjectViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withParams:(NSMutableDictionary*)params;

//Higher level API
- (CKObjectViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withObjectClass:(Class)objectClass;

@end