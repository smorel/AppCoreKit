//
//  CKCollectionTableViewCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"


/** This class allow to bind a collection with feedsource to an activity indicator/number of results view.
    It value MUST be a CKProperty object initialized with an object/keypath pointing to a CKCollection instance.
 */
@interface CKCollectionTableViewCellController : CKTableViewCellController 

@end
