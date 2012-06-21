//
//  CKFormBindedCollectionSection_private.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormBindedCollectionSection.h"

@interface CKFormBindedCollectionSection()
@property (nonatomic,retain) CKCollectionController* objectController;
@property (nonatomic,retain) CKCollectionCellControllerFactory* controllerFactory;

@property (nonatomic,retain,readwrite) NSMutableArray* headerCellControllers;
@property (nonatomic,retain,readwrite) NSMutableArray* footerCellControllers;
@end