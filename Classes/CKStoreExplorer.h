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


