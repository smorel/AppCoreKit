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
#import "CKFormTableViewController.h"

/**
 */
@interface CKStoreExplorer : CKFormTableViewController

///-----------------------------------
/// @name Initializing a CKStore Explorer
///-----------------------------------

/**
 */
- (id)initWithDomains:(NSArray *)domains;

@end


