//
//  CKGridTableViewCellController.h
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKGridTableViewCellController : CKTableViewCellController
@property(nonatomic,retain) CKItemViewControllerFactory* controllerFactory;
@property(nonatomic,assign) NSInteger numberOfColumns;
@property(nonatomic,retain) NSArray* cellControllers;
@end
