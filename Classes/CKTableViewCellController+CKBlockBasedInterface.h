//
//  CKTableViewCellController+CKBlockBasedInterface.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
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

@end