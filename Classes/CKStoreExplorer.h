//
//  CKStoreExplorer.h
//  Express
//
//  Created by Oli Kenobi on 10-01-24.
//  Copyright 2010 Kenobi Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKStore.h"
#import "CKItem.h"
#import "CKFormTableViewController.h"


/** TODO
 */
@interface CKStoreExplorer : CKFormTableViewController

///-----------------------------------
/// @name Initializing a CKStore Explorer
///-----------------------------------

/**
 */
- (id)initWithDomains:(NSArray *)domains;

@end



/** TODO
 */
@interface CKStoreDomainExplorer : CKFormTableViewController 

///-----------------------------------
/// @name Initializing a CKStore Domain Explorer
///-----------------------------------

/**
 */
- (id)initWithDomain:(NSString *)domain;

/**
 */
- (id)initWithItems:(NSMutableArray *)items;

@end



/** TODO
 */
@interface CKStoreItemExplorer : CKFormTableViewController 

///-----------------------------------
/// @name Initializing a CKStore item Explorer
///-----------------------------------

/**
 */
- (id)initWithItem:(CKItem *)item;

@end
