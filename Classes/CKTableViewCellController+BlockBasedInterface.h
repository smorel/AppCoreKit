//
//  CKTableViewCellController+BlockBasedInterface.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

/**
 */
@interface CKTableViewCellController (CKBlockBasedInterface)

///-----------------------------------
/// @name Customizing TableView Cell Controller Behaviour
///-----------------------------------

/**
 */
- (void)setDeallocBlock:(void(^)(CKTableViewCellController* controller))block;

/**
 */
- (void)setInitBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block;

/**
 */
- (void)setSetupBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block;

/**
 */
- (void)setSelectionBlock:(void(^)(CKTableViewCellController* controller))block;

/**
 */
- (void)setAccessorySelectionBlock:(void(^)(CKTableViewCellController* controller))block;

/**
 */
- (void)setBecomeFirstResponderBlock:(void(^)(CKTableViewCellController* controller))block;

/**
 */
- (void)setResignFirstResponderBlock:(void(^)(CKTableViewCellController* controller))block;

/**
 */
- (void)setViewDidAppearBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block;

/**
 */
- (void)setViewDidDisappearBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block;

/**
 */
- (void)setLayoutBlock:(void(^)(CKTableViewCellController* controller, UITableViewCell* cell))block;

/** This callback is called when the collection view commits editing changes to this cell controller.
 By default, removeCallback is nil.
 If you implements it you will have to manually remove the cell or the object from the binded collections.
 */
- (void)setRemoveBlock:(void(^)(CKTableViewCellController* controller))block;

@end