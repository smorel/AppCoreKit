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
    CKItemViewController* viewController;
}

@property (nonatomic,retain) id value;
@property (nonatomic,retain) id viewController;

- (id)initWithValue:(id)value controllerClass:(Class)controllerClass;
- (id)initWithItemViewController:(CKItemViewController*)controller;

+ (CKFormCellDescriptor*)cellDescriptorWithValue:(id)value controllerClass:(Class)controllerClass;
+ (CKFormCellDescriptor*)cellDescriptorWithItemViewController:(CKItemViewController*)controller;

@end
