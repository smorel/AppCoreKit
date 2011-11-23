//
//  CKItemViewControllerFactory.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKItemViewController.h"


/********************************* CKItemViewControllerFactoryItem *********************************
 */

/** TODO
 */
@interface CKItemViewControllerFactoryItem : NSObject{
	Class _controllerClass;
	NSMutableDictionary* _params;
}

@property(nonatomic,assign)Class controllerClass;
@property(nonatomic,retain,readonly)NSMutableDictionary* params;

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
- (CKCallback*)layoutCallback;

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
- (void)setLayoutBlock:(CKCallbackBlock)block;


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
- (void)setLayoutTarget:(id)target action:(SEL)action;

- (void)setFlags:(CKItemViewFlags)flags;
- (void)setFilterPredicate:(NSPredicate*)predicate;
- (void)setSize:(CGSize)size;

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


/********************************* CKItemViewControllerFactory *********************************
 */

/** TODO
 */
@interface CKItemViewControllerFactory : NSObject {
	NSMutableArray* _mappings;
	id _objectController;
}

@property (nonatomic, retain, readonly) NSMutableArray* mappings;
@property (nonatomic, assign, readonly) id objectController;

//construction
+ (CKItemViewControllerFactory*)factoryWithMappings:(NSArray*)mappings;   //should be deprecated
+ (id)factoryWithMappings:(NSArray*)mappings withFactoryClass:(Class)type;  //should be deprecated

//API
- (CKItemViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath;
- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end


/********************************* DEPRECATED *********************************
 */


//DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER
@interface CKObjectViewControllerFactoryItem : CKItemViewControllerFactoryItem
@end

//DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER
@interface CKObjectViewControllerFactory : CKItemViewControllerFactory
@end

@interface NSMutableArray (CKObjectViewControllerFactory_DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)
- (CKItemViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withParams:(NSMutableDictionary*)params DEPRECATED_ATTRIBUTE;
- (CKItemViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withObjectClass:(Class)objectClass DEPRECATED_ATTRIBUTE;
@end