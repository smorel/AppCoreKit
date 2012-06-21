//
//  CKCollectionController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectController.h"
#import "CKCollection.h"


/** TODO
 */
@interface CKCollectionController : NSObject<CKObjectController> 

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain,readonly) CKCollection* collection;

- (id)initWithCollection:(CKCollection*)collection;
+ (CKCollectionController*) controllerWithCollection:(CKCollection*)collection;

@property (nonatomic, assign) BOOL appendSpinnerAsFooterCell;
@property (nonatomic, assign) NSInteger maximumNumberOfObjectsToDisplay;

@end
