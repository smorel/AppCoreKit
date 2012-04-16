//
//  CKTableViewCellController+Responder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"


/** TODO
 */
@interface CKTableViewCellController(CKResponder)

- (BOOL)hasNextResponder;
- (BOOL)hasPreviousResponder;

- (BOOL)activateNextResponder;
- (BOOL)activatePreviousResponder;

//Responder Protocol for CKTableViewCellController
- (BOOL)hasResponder;
- (void)becomeFirstResponder;
- (UIView*)nextResponder:(UIView*)view;

@end
