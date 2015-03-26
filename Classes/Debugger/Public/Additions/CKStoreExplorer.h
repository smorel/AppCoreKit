//
//  CKStoreExplorer.h
//  AppCoreKit
//
//  Created by Oli Kenobi.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKStore.h"
#import "CKTableViewController.h"

/**
 */
@interface CKStoreExplorer : CKTableViewController

///-----------------------------------
/// @name Initializing a CKStore Explorer
///-----------------------------------

/**
 */
- (id)initWithDomains:(NSArray *)domains;

@end


