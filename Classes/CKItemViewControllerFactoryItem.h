//
//  CKItemViewControllerFactoryItem.h
//  CloudKit
//
//  Created by Martin Dufort on 11-11-25.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKItemViewController.h"


extern NSString* CKItemViewControllerFactoryItemCreate;
extern NSString* CKItemViewControllerFactoryItemInit;
extern NSString* CKItemViewControllerFactoryItemSetup;
extern NSString* CKItemViewControllerFactoryItemSelection;
extern NSString* CKItemViewControllerFactoryItemAccessorySelection;
extern NSString* CKItemViewControllerFactoryItemFlags;
extern NSString* CKItemViewControllerFactoryItemFilter;
extern NSString* CKItemViewControllerFactoryItemSize;
extern NSString* CKItemViewControllerFactoryItemBecomeFirstResponder;
extern NSString* CKItemViewControllerFactoryItemResignFirstResponder;
extern NSString* CKItemViewControllerFactoryItemLayout;

/********************************* CKItemViewControllerFactoryItem *********************************
 */

typedef CKItemViewController*(^CKItemViewControllerCreationBlock)(id object, NSIndexPath* indexPath);

/** TODO
 */
@interface CKItemViewControllerFactoryItem : NSObject{
	Class _controllerClass;
}

@property(nonatomic,assign)Class controllerClass;
@property(nonatomic,copy)CKItemViewControllerCreationBlock controllerCreateBlock;

- (CKCallback*)createCallback;
- (CKCallback*)initCallback;
- (CKCallback*)setupCallback;
- (CKCallback*)selectionCallback;
- (CKCallback*)accessorySelectionCallback;
- (CKCallback*)becomeFirstResponderCallback;
- (CKCallback*)resignFirstResponderCallback;
- (CKCallback*)viewDidAppearCallback;
- (CKCallback*)viewDidDisappearCallback;
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
- (void)setViewDidAppearBlock:(CKCallbackBlock)block;
- (void)setViewDidDisappearBlock:(CKCallbackBlock)block;
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
- (void)setViewDidAppearTarget:(id)target action:(SEL)action;
- (void)setViewDidDisappearTarget:(id)target action:(SEL)action;
- (void)setLayoutTarget:(id)target action:(SEL)action;

- (void)setFlags:(CKItemViewFlags)flags;
- (void)setFilterPredicate:(NSPredicate*)predicate;
- (void)setSize:(CGSize)size;

@end

/********************************* DEPRECATED *********************************
 */


//DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER
@interface CKObjectViewControllerFactoryItem : CKItemViewControllerFactoryItem
@end
