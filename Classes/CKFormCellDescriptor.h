//
//  CKFormCellDescriptor.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"
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
@property (nonatomic,retain) CKTableViewCellController* cellController;

- (id)initWithValue:(id)value controllerClass:(Class)controllerClass;
- (id)initWithCellController:(CKTableViewCellController*)controller;

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass;
+ (CKFormCellDescriptor*)cellDescriptorWithCellController:(CKTableViewCellController*)controller;

@end
