//
//  CKFormCellDescriptor.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"
#import "CKObjectTableViewController.h"
#import "CKTableViewCellController.h"
#import "CKObjectController.h"
#import "CKDocumentController.h"


typedef void(^CKFormCellInitializeBlock)(CKTableViewCellController* controller);


/** TODO
 */
@interface CKFormCellDescriptor : CKItemViewControllerFactoryItem{
	id _value;
    CKTableViewCellController* _cellController;
}

@property (nonatomic,retain) id value;
@property (nonatomic,retain) id cellController;

- (id)initWithValue:(id)value controllerClass:(Class)controllerClass;
- (id)initWithCellController:(CKTableViewCellController*)controller;

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass;
+ (CKFormCellDescriptor*)cellDescriptorWithCellController:(CKTableViewCellController*)controller;

@end
